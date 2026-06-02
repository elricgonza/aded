sudo rm -r ~/eduapp
cp -r ~/edu ~/eduapp
sudo rm -r ~/eduapp/.git
sudo rm -r ~/eduapp/.gitignore
sudo rm -r ~/eduapp/__pycache__
sudo rm -r ~/eduapp/app/__pycache__
sudo rm -r ~/eduapp/app/routes/__pycache__
tar -czvf eduapp.tar.gz eduapp/
