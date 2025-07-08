import pytest
import warnings

@pytest.fixture(params=["user1", "user2", "user3"])
def username(request):
    return request.param

@pytest.fixture(params=["/etc/test_shell"])
def file_path(request):
    return request.param

@pytest.fixture
def file(username):
    return f"/home/{username}/info.txt"

@pytest.fixture
def content(username):
    return f"Hostname: centos8\nUser: \{username}"

def test_os_release(host):
    assert host.file("/etc/os-release").contains("centos")

def test_group_exists(host):
    assert host.group("test_group").exists

def test_file_exist(host):
    assert host.file("/etc/test_shell").is_directory

def has_read_perm(host, username, file_path):
    with host.sudo(username):
        return host.run(f"test -r {file_path}").rc == 0

def has_write_perm(host, username, file_path):
    with host.sudo(username):
        return host.run(f"touch -c {file_path}/testfile 2>&1").rc == 0

def has_execute_perm(host, username, file_path):
    with host.sudo(username):
        return host.run(f"cd {file_path}").rc == 0

encrypted_passwords = {
    "user1": "$6$QBINfgJDtQdv/K7C$Lx/qz8p8Q/Eh6JrwJtE7dIgZzKjcNQSu2I4/NqPGajXsR6n3iQ7BuaBRcdpRU8UgM2n9bO9LfwjTKIwcTTYde/",
    "user2": "$6$H9VUAsKNvfbRhS70$tyJ2kEDLkPJU3kAGi92gCh.WCG9zVDM0/6hfhLWMuATftZ6wQ9j3.j0MsIL/Cqtks1PitB6ELcXE/hXaB8ZJk/",
    "user3": "$6$.uYJKB/YK8UeDBa4$IwkIKleougi3nbj2leqAyjoG0Br0/J4n5DCCXzRnuQGOgFAFQ8LK.I7QElv286zlczsnNpGuA./Mek7XvmxtP."
}
def test_users__exists(host, username):
    assert host.user(username).exists             
    with host.sudo(username):          
        command = host.run("echo $USER")
        assert username in command.stdout                                   # Check if USER_NAME env exist 
def test_user_in_group(host, username):
    assert "test_group" in host.user(username).groups                       # Test if user in "test_group" group
def test_user_password(host, username):
    with host.sudo():
        psw = host.user(username).password
        warnings.warn(UserWarning(f"User: {username} has encypted password: {psw}"))
        assert psw == encrypted_passwords[username]                         # Test if user password has been set  
def test_file_contains(host, username, file, content):
    with host.sudo(username):
        assert host.file(file).exists
        assert host.file(file).contains(content)
def test_user_in__sudo(host, username):
    with host.sudo(username): 
        assert host.run("sudo --validate").rc == 0                          # Check if user in sudoers without password
def test_ssh_deny(host, username):
    result = host.run(f"ssh {username}@localhost")
    assert result.rc != 0                                                   # Check if ssh denied                      

        
        

