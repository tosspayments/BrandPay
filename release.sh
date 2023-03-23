VERSION=`cat version`
echo $VERSION

git tag $VERSION
git push --tags
bundle exec pod trunk push BrandPay.podspec
