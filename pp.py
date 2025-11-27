import os, subprocess, sys


if len(sys.argv) < 2:
    message = 'merge'
else:
    message = sys.argv[1]


def format_number(number):
    # Convert number to a string
    num_str = str(number)

    result = list(num_str)
    while len(result) < 3:
        result.insert(0, '0')

    result = '.'.join(result)

    return result


def push(message):
    os.system('git add .')
    os.system(f'git commit -m "{message}"')
    os.system('git push -u origin master')


def pull():
    os.system('git config pull.rebase false')
    os.system('git pull origin master')


def init(repo_url):
    os.system('git init')
    os.system('git add .')
    os.system(f'git commit -m "Initial commit"')
    os.system(f'git remote add origin {repo_url}.git')
    os.system('git push -u origin master')


def push_pull(message):
    push(message)
    pull()

#init('https://github.com/zen-ham/HID_Arduino')

#result = subprocess.run(['git', 'rev-list', '--count', '--all'], capture_output=True, text=True)
#result = int(result.stdout.strip()) + 1

#with open('version', 'w') as f:
#    f.write(format_number(result))

for i in range(3):
    push_pull(message)
