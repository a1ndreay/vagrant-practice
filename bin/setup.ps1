param (
    [string]$VBOXPATH
)

# Create this files and paste content below into it.
# Note: Without this files, WSL2 will not connect to VirtualBox host.
# C:/Users/%UserProfile%/.wslconfig
# Для подключения к виртуальной машине по ssh изнутри WSL, мы 
# пробросили стандартные сетевые интерфейсы из хоста, позволяя 
# использовать тот же сетевой интерфейс, что изнутри VirtualBox. 
$wslConfigPath = "$env:USERPROFILE\.wslconfig"
$wslConfigContent = @"
[wsl2]
networkingMode=mirrored
dnsTunneling=true
"@

if (Test-Path $wslConfigPath) {
    Add-Content -Path $wslConfigPath -Value $wslConfigContent
} else {
    Set-Content -Path $wslConfigPath -Value $wslConfigContent
}

# Create this file in WSL, without it you cannot use linux permissions in DrvFs
# Это позволит примонтировать внутрь WSL файловую систему 
# windows как DrvFs для использования линуксовых файловых 
# метаданных, без этого ssh откажется использовать ключи.
# /etc/wsl.conf
$wslConfContent = @"
[automount]
enabled = true
options = "metadata,uid=1000,gid=1000,umask=0022,fmask=11,case=off"
mountFsTab = false
crossDistro = true
"@

$wslCommand = @"
if [ -f /etc/wsl.conf ]; then
    echo '$wslConfContent' | sudo tee -a /etc/wsl.conf
else
    echo '$wslConfContent' | sudo tee /etc/wsl.conf
fi
"@

wsl --exec bash -c $wslCommand

# Перезапуск WSL
wsl --shutdown
Start-Sleep -Seconds 8
wsl --exec bash -c "echo WSL restarted"

# Путь до монтированного в DrvFs бинарника VBoxManager.exe
$vboxPathWSL = $VBOXPATH -replace '^C:', '/mnt/c' -replace '\\', '/' 

# Необходимый stuff Vagrant
$bashrcCommands = @"
echo 'export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"' >> ~/.bashrc && \
echo "export VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH='/mnt/c/Users/\$(whoami)'" >> ~/.bashrc && \
echo 'export PATH="\$PATH:/mnt/c/WINDOWS/system32"' >> ~/.bashrc && \
echo 'export PATH="\$PATH:/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0"' >> ~/.bashrc && \
echo 'export PATH="\$PATH:$vboxPathWSL"' >> ~/.bashrc
"@

wsl --exec bash -c "sudo -u \$(id -nu 1000) bash -c '$bashrcCommands'"

# Установка плагина для vagrant
$requirenments = @"
vagrant-extra-vars
"@

$dirPathWSL = $PSScriptRoot -replace '^C:', '/mnt/c' -replace '\\', '/' 
$pluginInstallCommands = @"
cd $dirPathWSL && vagrant plugin install $requirenments
"@ 

wsl --exec bash -c "sudo -u \$(id -nu 1000) bash -c '$pluginInstallCommands'"

$packages = @"
python3-testinfra
"@
$installCommand = @"
sudo apt update && sudo apt install -y $packages
"@

wsl --exec bash -c "sudo -u \$(id -nu 1000) bash -c '$installCommand'"