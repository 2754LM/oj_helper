import requests

class ContesLeetcode:
    def __init__(self):
        self.baseUrl = 'https://leetcode.cn/u/lu-ming-b/'

    def getContests(self, count=5):
        response = requests.get(self.baseUrl)
        
if __name__ == '__main__':
    leetcode = ContesLeetcode()
    leetcode.getContests()