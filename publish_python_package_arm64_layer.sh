#! /bin/sh
set -e


package_names=$@
first_package_name=$1

echo publish layer $package_names for arm64 architecture as $first_package_name-Arm64
# cleanup workspace
rm -rf python && mkdir python

# install to directory
/opt/homebrew/bin/python3.11 -m pip --python /opt/homebrew/bin/python3.11 \
    install \
    --platform manylinux2014_aarch64 \
    --implementation cp \
    --target=./python \
    --only-binary=:all: --upgrade \
    $package_names

# delete tests filder
find python/ -type d -name 'tests' -exec rm -rf {} +

# make zip package
rm -f python.zip & zip -vr python.zip python/ -x "tests" -x "*.pyc"

# push to aws
aws lambda publish-layer-version --layer-name $first_package_name-Arm64 --description "$package_names python3.11 arm64"  \
	--license-info "MIT" --zip-file fileb://python.zip \
 	--compatible-runtimes python3.11 \
  	--compatible-architectures "arm64" \
  	--region ap-southeast-1

aws lambda publish-layer-version --layer-name $first_package_name-Arm64 --description "$package_names python3.11 arm64"  \
	--license-info "MIT" --zip-file fileb://python.zip \
 	--compatible-runtimes python3.11 \
  	--compatible-architectures "arm64" \
  	--region eu-west-3