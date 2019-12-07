# Stop all containers. Remove All containers. Remove all images. Nuke.

# How to list all containers compactly and stop/remove individual containers
echo "Stopping Containers"
docker container stop $(docker container ls -aq)

echo "Removing Images"
docker system prune -a --force

echo "Done"