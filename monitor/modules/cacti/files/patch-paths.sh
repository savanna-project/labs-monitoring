#!/bin/bash
grep -rl "chdir('../.*');" . | xargs sed -i -e "s/chdir('.*');/chdir('\/usr\/share\/cacti\/site')/g"
