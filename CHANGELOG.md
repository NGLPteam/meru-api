# Changelog

## 1.0.0 (2026-11-09)


### Features

* add canPreview to entities ([0e13736](https://github.com/NGLPteam/meru-api/commit/0e13736d109808bc89bc707f6b93926581370540))
* add keywords to all item metadata layouts ([2af4d48](https://github.com/NGLPteam/meru-api/commit/2af4d48c5d96a8c34a31b4f0f0b9451e93683c72))
* allow submissions to be destroyed ([ad94eb7](https://github.com/NGLPteam/meru-api/commit/ad94eb72f6cc64a1fd3e57d307857256063daf20))
* delete pending reviews when publishing ([589e353](https://github.com/NGLPteam/meru-api/commit/589e3535289abb8dd00f7693c81cb6da307c6976))
* make harvest attempt default sorting more semantic ([ec97fc1](https://github.com/NGLPteam/meru-api/commit/ec97fc1a7f0af4643d0397fe483b46302d8db0bf))


### Bug Fixes

* actually actually handle S3 CDNs with shrine ([2cf018b](https://github.com/NGLPteam/meru-api/commit/2cf018be60950a63467e4c41367c35cb303a77ab))
* add stuck attachment processing ([af31040](https://github.com/NGLPteam/meru-api/commit/af310406ac2578d2127694a0f23fa2f15e69dc42))
* adjust standard metadata ([790316e](https://github.com/NGLPteam/meru-api/commit/790316e64d83d0c8ec4d6d4c85b3761a7c2b5f0c))
* allow related models to invalidate entity caches ([0c3f219](https://github.com/NGLPteam/meru-api/commit/0c3f2199081f4ddd4f84b4434eb17ea1478601f5))
* clean up shared contexts + auth checks ([7e9560d](https://github.com/NGLPteam/meru-api/commit/7e9560dac3b4339a9976b9edacc1845207362f1f))
* **deps:** update gems ([52f76da](https://github.com/NGLPteam/meru-api/commit/52f76da916a346874de5a6fad0ce307f778716ce))
* force service call ([8b6541e](https://github.com/NGLPteam/meru-api/commit/8b6541e294045cc7ee3b83d1b465ec956bc67b09))
* **harvesting:** correctly guard against changes ([054aa20](https://github.com/NGLPteam/meru-api/commit/054aa2042ba296ca5471758f794a939f1a6cc163))
* **harvesting:** don't cache asset fetching in production ([75dcf4a](https://github.com/NGLPteam/meru-api/commit/75dcf4afa4a41e95941477aa68d52bdcc0d5f59e))
* improve entity visibility/ordering interactions ([cf17fce](https://github.com/NGLPteam/meru-api/commit/cf17fce2141bdae3b97f2ae56e602da363b02ea7))
* preserve all job records for stuck processing ([65db3dd](https://github.com/NGLPteam/meru-api/commit/65db3ddba3c564d1a87a7160aaaa957dc8f337f7))
* process shrine attachments more robustly ([f9026dc](https://github.com/NGLPteam/meru-api/commit/f9026dc2b62aec189ca62f1cf2081888bcd2ca6c))
* properly handle hidden entity permissions ([9cd9d38](https://github.com/NGLPteam/meru-api/commit/9cd9d385248ea4e6754b52c8df683cbfa9627043))
* support presigned URLs with CDNs in Shrine ([1cb1eb2](https://github.com/NGLPteam/meru-api/commit/1cb1eb21d6061a029e0a22d72848d74ecf16eb73))
* update CI vips install, action version update pass ([f6938f3](https://github.com/NGLPteam/meru-api/commit/f6938f3f73a35d2c1dc2fe8fcb9177481d4bae02))
