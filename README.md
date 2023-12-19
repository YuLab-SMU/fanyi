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
caused by language.

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

use `set_translate_source()` to set the default translator using in
`translate()`

### to use `baidu` translate:

1.  go to <https://fanyi-api.baidu.com/manage/developer> and regist as
    an individual developer
2.  get `appid` and `key` (密钥)
3.  set `appid` and `key` with `source = "baidu"` using
    `set_translate_option()`
4.  have fun with `translate()`

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
6.  have fun with `translate()`

## :ideograph_advantage: Examples

``` r
library(fanyi)

##
## run `set_translate_option()` to setup
##

text <- 'clusterProfiler supports exploring functional characteristics 
    of both coding and non-coding genomics data for thousands of species 
    with up-to-date gene annotation'
translate(text, from='en', to='zh')
```

    ## [1] "clusterProfiler支持通过最新的基因注释探索数千个物种的编码和非编码基因组学数据的功能特征"

``` r
translate(text, from='en', to='jp')
```

    ## [1] "clusterProfilerは、最新の遺伝子注釈による数千種の種の符号化および非符号化ゲノム学データの機能的特徴の探索を支援する"

``` r
library(DOSE)
library(enrichplot)
data(geneList)
de <- names(geneList)[1:200]
x <- enrichDO(de)
p <- dotplot(x)
p2 <- translate_ggplot(p, axis='y')
aplot::plot_list(p, p2)
```

![](README_files/figure-gfm/ggplot-fanyi-1.png)

``` r
library(fanyi)
symbol <- c("LDHB", "CCR7", "CD3D", "CD3E", "LEF1", "NOSIP")
gene <- clusterProfiler::bitr(symbol, 
            fromType = 'SYMBOL', 
            toType = 'ENTREZID', 
            OrgDb = 'org.Hs.eg.db')
```

    ## 

    ## 

    ## 'select()' returned 1:1 mapping between keys and columns

``` r
gene
```

    ##   SYMBOL ENTREZID
    ## 1   LDHB     3945
    ## 2   CCR7     1236
    ## 3   CD3D      915
    ## 4   CD3E      916
    ## 5   LEF1    51176
    ## 6  NOSIP    51070

``` r
res <- gene_summary(gene$ENTREZID)
head(res, 2)
```

    ##       uid name                    description
    ## 3945 3945 LDHB        lactate dehydrogenase B
    ## 1236 1236 CCR7 C-C motif chemokine receptor 7
    ##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     summary
    ## 3945                                                                                                                                                                             This gene encodes the B subunit of lactate dehydrogenase enzyme, which catalyzes the interconversion of pyruvate and lactate with concomitant interconversion of NADH and NAD+ in a post-glycolysis process. Alternatively spliced transcript variants have been found for this gene. Recent studies have shown that a C-terminally extended isoform is produced by use of an alternative in-frame translation termination codon via a stop codon readthrough mechanism, and that this isoform is localized in the peroxisomes. Mutations in this gene are associated with lactate dehydrogenase B deficiency. Pseudogenes have been identified on chromosomes X, 5 and 13. [provided by RefSeq, Feb 2016]
    ## 1236 The protein encoded by this gene is a member of the G protein-coupled receptor family. This receptor was identified as a gene induced by the Epstein-Barr virus (EBV), and is thought to be a mediator of EBV effects on B lymphocytes. This receptor is expressed in various lymphoid tissues and activates B and T lymphocytes. It has been shown to control the migration of memory T cells to inflamed tissues, as well as stimulate dendritic cell maturation. The chemokine (C-C motif) ligand 19 (CCL19/ECL) has been reported to be a specific ligand of this receptor. Signals mediated by this receptor regulate T cell homeostasis in lymph nodes, and may also function in the activation and polarization of T cells, and in chronic inflammation pathogenesis. Alternative splicing of this gene results in multiple transcript variants. [provided by RefSeq, Sep 2014]

``` r
translate(res$description)
```

    ## [1] "乳酸脱氢酶B"               "C-C基序趋化因子受体7"     
    ## [3] "T细胞受体复合体的CD3δ亚基" "T细胞受体复合体的CD3ε亚基"
    ## [5] "淋巴增强因子结合因子1"     "一氧化氮合酶相互作用蛋白"

``` r
translate(res$summary[1])
```

    ## [1] "该基因编码乳酸脱氢酶的B亚基，该亚基在糖酵解后过程中催化丙酮酸和乳酸的相互转化以及伴随的NADH和NAD+的相互转化。已经发现了该基因的选择性剪接转录物变体。最近的研究表明，通过终止密码子通读机制，通过使用替代的框内翻译终止密码子产生C端延伸的亚型，并且该亚型定位于过氧化物酶体中。该基因的突变与乳酸脱氢酶B缺乏有关。在X、5和13号染色体上已鉴定出假基因。【RefSeq提供，2016年2月】"
