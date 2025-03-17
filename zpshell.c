// A shell program I developed

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>
#include <stdbool.h>
#include <errno.h>

#define INPUT_LENGTH 2048
#define MAX_ARGS 512
#define MAX_BG_PROCESSES 100

struct command_line {
    char *argv[MAX_ARGS + 1];
    int argc;
    char *input_file;
    char *output_file;
    bool is_bg;
};

// Global variables
int last_status = 0;
bool fg_only_mode = false;
bool waiting_for_fg = false;
pid_t bg_pids[MAX_BG_PROCESSES];
int bg_count = 0;

void handle_SIGTSTP(int signo) {
    if (waiting_for_fg) return;
    if (fg_only_mode) {
        write(STDOUT_FILENO, "Exiting foreground-only mode\n", 29);
        fg_only_mode = false;
    } else {
        write(STDOUT_FILENO, "Entering foreground-only mode (& is now ignored)\n", 49);
        fg_only_mode = true;
    }
}

void check_bg_processes() {
    for (int i = 0; i < bg_count; i++) {
        int status;
        pid_t result = waitpid(bg_pids[i], &status, WNOHANG);
        if (result > 0) {
            if (WIFEXITED(status)) {
                printf("background pid %d is done: exit value %d\n", result, WEXITSTATUS(status));
            } else if (WIFSIGNALED(status)) {
                printf("background pid %d is done: terminated by signal %d\n", result, WTERMSIG(status));
            }
            fflush(stdout);
            bg_pids[i] = bg_pids[--bg_count];
        }
    }
}

struct command_line *parse_input() {
    char input[INPUT_LENGTH];
    struct command_line *cmd = calloc(1, sizeof(struct command_line));

    printf(": ");
    fflush(stdout);
    fgets(input, INPUT_LENGTH, stdin);
    
    if (input[0] == '#' || input[0] == '\n') return cmd;
    
    char *token = strtok(input, " \n");
    while (token) {
        if (strcmp(token, "<") == 0) {
            cmd->input_file = strdup(strtok(NULL, " \n"));
        } else if (strcmp(token, ">") == 0) {
            cmd->output_file = strdup(strtok(NULL, " \n"));
        } else if (strcmp(token, "&") == 0) {
            cmd->is_bg = !fg_only_mode;
        } else {
            cmd->argv[cmd->argc++] = strdup(token);
        }
        token = strtok(NULL, " \n");
    }
    return cmd;
}

void execute_command(struct command_line *cmd) {
    if (cmd->argc == 0) return;
    
    if (strcmp(cmd->argv[0], "exit") == 0) {
        exit(0);
    } else if (strcmp(cmd->argv[0], "cd") == 0) {
        chdir(cmd->argc > 1 ? cmd->argv[1] : getenv("HOME"));
    } else if (strcmp(cmd->argv[0], "status") == 0) {
        printf("exit value %d\n", last_status);
        fflush(stdout);
    } else {
        pid_t child_pid = fork();
        if (child_pid == 0) { // Child process
            if (cmd->input_file) {
                int in_fd = open(cmd->input_file, O_RDONLY);
                if (in_fd == -1) {
                    perror("cannot open input file");
                    exit(1);
                }
                dup2(in_fd, STDIN_FILENO);
                close(in_fd);
            } else if (cmd->is_bg) {
                int null_fd = open("/dev/null", O_RDONLY);
                dup2(null_fd, STDIN_FILENO);
                close(null_fd);
            }

            if (cmd->output_file) {
                int out_fd = open(cmd->output_file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
                if (out_fd == -1) {
                    perror("cannot open output file");
                    exit(1);
                }
                dup2(out_fd, STDOUT_FILENO);
                close(out_fd);
            } else if (cmd->is_bg) {
                int null_fd = open("/dev/null", O_WRONLY);
                dup2(null_fd, STDOUT_FILENO);
                close(null_fd);
            }

            execvp(cmd->argv[0], cmd->argv);
            perror("exec failure");
            exit(1);
        } else {
            if (cmd->is_bg) {
                printf("background pid is %d\n", child_pid);
                fflush(stdout);
                bg_pids[bg_count++] = child_pid;
            } else {
                waiting_for_fg = true;
                int status;
                waitpid(child_pid, &status, 0);
                waiting_for_fg = false;
                if (WIFEXITED(status)) {
                    last_status = WEXITSTATUS(status);
                } else if (WIFSIGNALED(status)) {
                    printf("terminated by signal %d\n", WTERMSIG(status));
                    fflush(stdout);
                    last_status = 1;
                }
            }
        }
    }
}

int main() {
    struct sigaction SIGTSTP_action = {0};
    SIGTSTP_action.sa_handler = handle_SIGTSTP;
    sigaction(SIGTSTP, &SIGTSTP_action, NULL);
    
    while (1) {
        check_bg_processes();
        struct command_line *cmd = parse_input();
        execute_command(cmd);
        free(cmd);
    }
}
