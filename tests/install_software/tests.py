import testinfra
import os
import json

# https://testinfra.readthedocs.io/en/latest/modules.html#testinfra.modules.file.File

def test_os_release(host):
    assert host.file("/etc/os-release").contains("centos")

def test_httpd_service(host):
    httpd = host.service("httpd")
    assert httpd.is_running
    assert httpd.is_enabled

def test_index_html(host):
    index_file = host.file("/var/www/html/index.html")
    assert index_file.exists

def test_network(host):
    google = host.addr("google.com")
    assert google.is_reachable

def test_httpd_port(host):
    socket = host.socket("tcp://0.0.0.0:80")
    assert socket.is_listening

def test_firewall(host):
    firewall = host.service("firewalld")
    assert firewall.is_running
    assert firewall.is_enabled
    with host.sudo():
        assert "http https" in host.check_output("firewall-cmd --zone=public --list-services")

def test_httpd_index_page(host):
    command = host.run("curl -s http://localhost:80")
    assert command.rc == 0
    assert "System Information" in command.stdout

