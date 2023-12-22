# fanyi 0.0.5.008

+ fixed #4 issue when multiple words translated into identical target (2023-12-22, Fri)
    - e.g., 'esophageal carcinoma' and 'esophageal cancer' are translated into one identical Chinese word
    - now the translated word will be labeled with original words to differentiate
+ `get_summary()` and translators with cache  (2023-12-21, Thu)
+ `youdao_translate()` supports using youdao translate service (2023-12-20, Wed, #2)
+ `gene_summary()` to query gene summary and `symbol2entrez()` to convert ID, both using NCBI Gene database (2023-12-19, Tue)
+ `translate_ggplot()` allows translating axis labels of a ggplot (2023-12-19, Tue)
+ `bing_translate()` supports using bing translate service (2023-12-19, Tue, #1)
+ introduce 'source' parameter in `get_translate_appkey()` (2023-12-17, Sun)
+ `set_translate_option()` supports storing multiple appid and key for different translators (although currently only 'baidu' is supported) (2023-12-16, Sat)

# fanyi 0.0.5

+ `translate()` which is a generic interface and would expand to allow using other translators (2023-12-14, Thu)
+ `set_translate_option()` allows users to use their own appid and key and it is a must now (2023-12-13, Wed)
+ `cn2en()` and `cn2en()` to translate between English and Chinese (2023-12-12, Tue)
+ `baidu_translate()` to translate sentences (2023-12-11, Mon)

