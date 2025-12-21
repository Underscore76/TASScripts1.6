import subprocess
import time
for i in range(100):
	print(time.time())
	subprocess.run(['zsh','-i','-c','smapi'])
	time.sleep(1)
print(time.time())

