'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "index.html": "49024333c86d5f83b0283415f1013175",
"/": "49024333c86d5f83b0283415f1013175",
"main.dart.js": "39f62f051ba05d4ccc8a1e440357f75a",
"favicon.png": "c44f54d0521b7c14562539eab5da4565",
"icons/Icon-192.png": "9cce240a8c959ee2d167b1ef3c36fae3",
"icons/Icon-512.png": "8a4d078e9360e26d9029d9f9b270bdad",
"manifest.json": "a72d3975920624ae930644d021e7ba7d",
"assets/LICENSE": "359934343d01819419e55db20d9ba1da",
"assets/AssetManifest.json": "99914b932bd37a50b983c5e7c90ae93b",
"assets/FontManifest.json": "580ff1a5d08679ded8fcf5c6848cece7",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
