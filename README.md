


## this is a project that translate things in R

#### if you want to use baidu translatte:

1. `https://fanyi-api.baidu.com/manage/developer` regist here as personal developer
2. get APP ID and 密钥 
3. source both `baidu.r` and `translate.r`
4. set  APP ID and 密钥  in `set_translate_option()`
5. call `translate`

#### If you want to use bing translate:

+ you need to open a free azure account and enable `Azure AI services | Translator` from `https://portal.azure.com/`, you need a visa/master card to complete registion.
+ create a translator service with free tier pricing version, find your key and region in the app you created. will not charge you until exceed monthly 2 million
+ set your key & location via `set_translate_option()`
+ then call `translate_bing`