##Update Repository##

sudo apt-get update
sudo apt-add-repository -y ppa:ansible/ansible

##refresh the package##

sudo apt-get update

##install Ansible##

sudo apt-get install -y ansible

##install dependency python##

sudo apt install python-pip -y

##check ansible version##

ansible --version