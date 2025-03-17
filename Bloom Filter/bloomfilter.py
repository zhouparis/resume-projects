# Paris Zhou
# CS370 Bloom Filter

import hashlib
from bitarray import bitarray
import math

class BloomFilter:
    def __init__(self, items_count, fp_probability):
        self.fp_prob = fp_probability
        self.size = self.get_size(items_count, self.fp_prob)
        self.hash_count = self.get_hash_count(self.size, items_count)
        self.bit_array = bitarray(self.size)
        self.bit_array.setall(0)

    def add(self, item):
        for index in range(self.hash_count):
            digest = int(hashlib.sha256(f"{item}{index}".encode()).hexdigest(), 16) % self.size
            self.bit_array[digest] = 1

    def check(self, item):
        for index in range(self.hash_count):
            digest = int(hashlib.sha256(f"{item}{index}".encode()).hexdigest(), 16) % self.size
            if self.bit_array[digest] == 0:
                return False
        return True

    def get_size(self, n, p):
        '''
        Size of bit array (m) 
        Expected number of items (n)
        False positive probability (p)
        '''
        m = -(n * math.log(p)) / (math.log(2) ** 2)
        return int(m)
    
    def get_hash_count(self, m, n):
        '''
        Optimal number of hash functions (k) 
        Size of the bit array (m) 
        Number of expected items (n)
        '''
        k = (m / n) * math.log(2)
        return int(k)

# Initialization
# 14344391 items in rockyou.txt, shooting for 0.05% FP probability
bloom = BloomFilter(14344391, 0.05)
rockyou_set = set()



true_positives = true_negatives = false_positives = false_negatives = 0

with open('rockyou.txt', 'r',encoding='ISO-8859-1') as file:
    for line in file:
        word = line.strip()
        bloom.add(word)
        rockyou_set.add(word)
        true_positives += 1 # Words both in the bloom filter and in the rockyou set are true positives

with open('dictionary.txt', 'r') as file:
    for line in file:
        word = line.strip()
        in_filter = bloom.check(word)
        if in_filter and (word not in rockyou_set):
            print(f"{word} is probably in the set")
            false_positives += 1
        elif not in_filter and (word in rockyou_set):
            false_negatives += 1
        else:
            print(f"{word} is definitely not in the set")
            true_negatives += 1

# Display statistics
print(f"True Positives: {true_positives}")
print(f"False Positives: {false_positives}")
print(f"True Negatives: {true_negatives}")
print(f"False Negatives: {false_negatives}")