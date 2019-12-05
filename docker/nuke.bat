@echo off
REM Stop all containers. Remove All containers. Remove all images. Nuke.

REM How to list all containers compactly and stop/remove individual containers
set _list_containers_cmd=docker container ls -aq
set _stop_container=docker container stop
set _remove_container=docker container rm

REM Loop through all contianers and stop them
echo "Stopping Containers:"
FOR /f %%G IN ('%_list_containers_cmd%') DO (%_stop_container% %%G & %_remove_container% %%G)

REM Remove all images
echo "Removing Images"
docker system prune -a --force

echo "Done"
