<!-- README.md is generated from README.Rmd. Please edit that file -->

# `fanyi`: Translate Words or Sentences via Online Translators

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/fanyi?color=green)](https://cran.r-project.org/package=fanyi)
![](http://cranlogs.r-pkg.org/badges/grand-total/fanyi?color=green)
![](http://cranlogs.r-pkg.org/badges/fanyi?color=green)
![](http://cranlogs.r-pkg.org/badges/last-week/fanyi?color=green)

Useful functions to translate text for multiple languages using online
translators. For example, by translating error messages and descriptive
analysis results into a language familiar to the user, it enables a
better understanding of the information, thereby reducing the barriers
caused by language. It offers several helper functions to query gene
information to help interpretation of interested genes (e.g., marker
genes, differential expression genes), and provides utilities to
translate ggplot graphics.

To cite fanyi in publications use:

G Yu. Using fanyi to assist research communities in retrieving and
interpreting information. ***bioRxiv***, 2023. doi:
[10.1101/2023.12.21.572729](https://www.biorxiv.org/content/10.1101/2023.12.21.572729).

## :writing_hand: Authors

Guangchuang YU

School of Basic Medical Sciences, Southern Medical University

<https://yulab-smu.top>

## :arrow_double_down: Installation

Get the released version from CRAN:

``` r
install.packages("fanyi")
```

Or the development version from github:

``` r
## install.packages("yulab.utils")
yulab.utils::install_zip_gh("YuLab-SMU/fanyi")
```

## :beginner: Usages

### to switch from different online translators:

You should use `set_translate_source()` to set the default translator
using in `translate()`.

Alternatively, you can call specific functions to use a specific
translator, (e.g., `baidu_translate()`, `bing_translate()`,
`youdao_translate()`, etc.).

### to use `baidu` translate:

1.  go to <https://fanyi-api.baidu.com/manage/developer> and regist as
    an individual developer
2.  get `appid` and `key` (密钥)
3.  set `appid` and `key` with `source = "baidu"` using
    `set_translate_option()`
4.  have fun with `baidu_translate()`

### to use `bing` translate:

1.  regist a free azure account
2.  enable `Azure AI services | Translator` from
    <https://portal.azure.com/>
3.  create a translation service with free tier pricing version (you
    need a visa/master card to complete registion and will not be
    charged until exceed 2 million characters monthly)
4.  get your `key` and `region`
5.  set `key` and `region` with `source = "bing"` using
    `set_translate_option()`
6.  have fun with `bing_translate()`

### to use `youdao`(有道智云) translate:

1.  go to <https://ai.youdao.com/> and register an account
2.  click `自然语言翻译服务` and create an app from subsection
    `文本翻译`
3.  get your `应用ID` as appid, and `应用秘钥` as key
4.  set `appid` and `key` with `source = "youdao"` using
    `set_translate_option()`
5.  have fun with `youdao_translate()`
6.  (bonus) you can also create `术语表` (dictionary for the terms) as a
    user-defined dictionary and get the dict id to help you get precise
    translation in certain domain.

### to use `volcengine` (火山引擎) translate:

1.  go to <https://www.volcengine.com/> and register an account
2.  enable `Machine Translation` (`机器翻译`)
3.  get app key
    - click `控制台`
    - click your avatar at the upper-right corner
    - select `API访问密钥`
    - click `新建密钥`
4.  for security concerns, you are highly advised to add a sub-account
    (新建子用户)
5.  click the subaccount name in `身份管理` - `用户`, and click
    `permissions` (权限)
6.  in `Global permissions` (全局权限), add the following permissions:
    “TranslateFullAccess”、“I18nTranslateFullAccess”
7.  set `appid` and `key` with `source = "volcengine"` and have fun with
    `volcengine_translate()`

### to use `caiyun` (彩云小译) translate:

1.  go to <https://platform.caiyunapp.com/login> and register
2.  login with your account, create a translation app (`创建应用`)
    choose `翻译` as `接口类型`
3.  get the token, set it as the `key` with `source = "caiyun"` using
    `set_translate_option()`
4.  have fun with `caiyun_translate()`
5.  caiyun currently supports `from` = {zh(中文), en, ja(日语),
    auto(自动识别)} and `to` = {en, ja, zh}, default `from` is `auto`

### to use `tencent` (腾讯机器翻译) translate:

1.  go to <https://console.cloud.tencent.com> and register;
2.  login with your account, go to
    <https://console.cloud.tencent.com/tmt> to enable machine
    translation (启用机器翻译);
3.  go to <https://console.cloud.tencent.com/cam/user/userType>, create
    a sub-account, in `Permissions` (权限) - `Permissions policy`
    (权限策略), search and add `QcloudTMTReadOnlyAccess`;
4.  get your API keys at `API keys` (API 密钥) of the same page in
    step 3. 

    Set `SecretId` as the `appid`;

    `SecretKey` as `key`

    respectively with `source = "tencent"` using
    `set_translate_option()`
5.  have fun with `tencent_translate()`
6.  for supported languages, visit
    <https://cloud.tencent.com/document/product/551/15611> for more
    information.

### to use `chatglm` (智谱清言[ChatGLM](https://arxiv.org/abs/2210.02414)) translate:

1.  go to <https://open.bigmodel.cn> and register;
2.  login with your account, go to
    <https://open.bigmodel.cn/usercenter/apikeys> to get your API key;
3.  set the one-line API key as `key` (no need for setting `appid`) with
    `source = "chatglm"` using `set_translate_option()`
4.  have fun with `chatglm_translate()`
5.  you can also set model you prefer to use with the option
    `user_model` when using `set_translate_option()`, 

    currently:
    
    a. `user_model` can be set as `turbo`, `pro`, `standard`, `lite`;
    
    b. `version` can be set as `v3` or `v4`.

### helper functions:

- `gene_summary()` allows retrieving gene information from NCBI.
- `translate_ggplot()` allows translating axis labels of a ggplot graph.
- `ydict()` allows query word from youdao dictionary.

## :ideograph_advantage: Examples

``` r
library(fanyi)

##
## run `set_translate_option()` to setup
##

text <- '我都不知道做人该怎么办，总之报纸写啥就信啥，电视演啥我就看啥。'
```

``` r
translate(text, from='zh', to='en')
```

> I don’t even know what to do as a person. In short, I believe whatever
> is written in the newspaper and watch whatever is shown on TV.

``` r
translate(text, from='zh', to='th')
```

> ผมไม่รู้ว่าการเป็นมนุษย์ควรทําอย่างไร สรุปแล้วหนังสือพิมพ์เขียนอะไรก็เชื่ออย่างนั้น
> ทีวีเล่นอะไรก็อ่านอย่างนั้น

``` r
translate(text, from='zh', to='jp')
```

> 私は人間としてどうすればいいのか分からないが、とにかく新聞は何を書いても何を信じても、テレビは何を演じても私は何を見てもいい。

``` r
translate(text, from='zh', to='fra')
```

> Je ne sais pas quoi faire en tant que personne, je crois ce que les
> journaux écrivent, je regarde ce que la télévision fait.

``` r
library(DOSE)
library(enrichplot)
data(geneList)
de <- names(geneList)[1:200]
x <- enrichDO(de)
p <- dotplot(x)
p2 <- translate_ggplot(p, axis='y')
p3 <- translate_ggplot(p, axis='y', to='kor')
p4 <- translate_ggplot(p, axis='y', to='ara')
aplot::plot_list(English = p, Chinese = p2, 
                Korean = p3, Arabic = p4, ncol=2)
```

![](README_files/figure-gfm/ggplot-fanyi-1.png)<!-- -->

``` r
ydict("cell")
```

    ## 
    ##  UK: [sel]   US: [sel]
    ## 
    ##  Explains: n. 细胞；小牢房；电解槽，电池；电芯；（政治组织的）小组，基层组织；（修道院中的）单人小室；（巢穴中单个的）巢室；（计算机屏幕上的）单元格
    ## 
    ##  Web: https://m.youdao.com/m/result?lang=en&word=cell

``` r
symbol <- c("CCR7", "CD3E")
gene <- clusterProfiler::bitr(symbol, 
            fromType = 'SYMBOL', 
            toType = 'ENTREZID', 
            OrgDb = 'org.Hs.eg.db')

gene
```

    ##   SYMBOL ENTREZID
    ## 1   CCR7     1236
    ## 2   CD3E      916

``` r
res <- gene_summary(gene$ENTREZID)
names(res)
```

    ## [1] "uid"         "name"        "description" "summary"

``` r
d <- data.frame(desc=res$description,
              desc2=translate(res$description))
d
```

    ##                                             desc                     desc2
    ## 1                 C-C motif chemokine receptor 7      C-C基序趋化因子受体7
    ## 2 CD3 epsilon subunit of T-cell receptor complex T细胞受体复合体的CD3ε亚基

``` r
res$summary
```

> \[1\] The protein encoded by this gene is a member of the G
> protein-coupled receptor family. This receptor was identified as a
> gene induced by the Epstein-Barr virus (EBV), and is thought to be a
> mediator of EBV effects on B lymphocytes. This receptor is expressed
> in various lymphoid tissues and activates B and T lymphocytes. It has
> been shown to control the migration of memory T cells to inflamed
> tissues, as well as stimulate dendritic cell maturation. The chemokine
> (C-C motif) ligand 19 (CCL19/ECL) has been reported to be a specific
> ligand of this receptor. Signals mediated by this receptor regulate T
> cell homeostasis in lymph nodes, and may also function in the
> activation and polarization of T cells, and in chronic inflammation
> pathogenesis. Alternative splicing of this gene results in multiple
> transcript variants. \[provided by RefSeq, Sep 2014\]

> \[2\] The protein encoded by this gene is the CD3-epsilon polypeptide,
> which together with CD3-gamma, -delta and -zeta, and the T-cell
> receptor alpha/beta and gamma/delta heterodimers, forms the T-cell
> receptor-CD3 complex. This complex plays an important role in coupling
> antigen recognition to several intracellular signal-transduction
> pathways. The genes encoding the epsilon, gamma and delta polypeptides
> are located in the same cluster on chromosome 11. The epsilon
> polypeptide plays an essential role in T-cell development. Defects in
> this gene cause immunodeficiency. This gene has also been linked to a
> susceptibility to type I diabetes in women. \[provided by RefSeq, Jul
> 2008\]

``` r
translate(res$summary)
```

> \[1\]
> 该基因编码的蛋白质是G蛋白偶联受体家族的成员。该受体被鉴定为EB病毒（EBV）诱导的基因，被认为是EB病毒对B淋巴细胞影响的媒介。这种受体在各种淋巴组织中表达，并激活B和T淋巴细胞。它已被证明可以控制记忆T细胞向炎症组织的迁移，并刺激树突细胞成熟。据报道，趋化因子（C-C基序）配体19（CCL19/ECL）是该受体的特异性配体。该受体介导的信号调节淋巴结中的T细胞稳态，也可能在T细胞的激活和极化以及慢性炎症发病机制中发挥作用。该基因的选择性剪接导致多种转录物变体。【RefSeq提供，2014年9月】

> \[2\]
> 该基因编码的蛋白质是CD3ε多肽，其与CD3γ、-Δ和-ζ以及T细胞受体α/β和γ/Δ异二聚体一起形成T细胞受体-CD3复合物。这种复合物在将抗原识别与几种细胞内信号转导途径偶联方面起着重要作用。编码ε、γ和δ多肽的基因位于11号染色体上的同一簇中。ε多肽在T细胞发育中起着重要作用。这种基因的缺陷会导致免疫缺陷。该基因也与女性易患I型糖尿病有关。【RefSeq提供，2008年7月】

## :book: Documents

- [把R当成你的翻译器](https://mp.weixin.qq.com/s/caHpUOyTqToJn6tqNspIyg)
- [fanyi支持有道智云，每年立省30万！](https://mp.weixin.qq.com/s/x829_4P7bui_zEbn3GrIyw)
- [不仅仅是翻译的fanyi包](https://mp.weixin.qq.com/s/E2jBPKs083bKJFX3gitjNg)
