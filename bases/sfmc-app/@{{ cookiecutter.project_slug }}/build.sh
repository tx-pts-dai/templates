echo "Running build.sh"
#!/bin/bash
mkdir build

# Build client

cd client
npm install
npm run build
cd ..

# Build server

cd server
npm install
npm run build
cd ..

# Copy server build

cp -a server/build/. build
cp server/package.json build
cp server/package-lock.json build

# Create public folder
# Copy client and jbca-config.json

mkdir build/src/public
cp -a client/build/. build/src/public
# cp server/src/public/jbca-config.json build/src/public

# Remove unnecessary folders

rm -r client
rm -r server
cp -a build/. ./
rm -r build

npm install

echo "Finished running build.sh"
