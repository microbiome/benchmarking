Overview
--------

This report contains benchmarking results for the melt operation with
common microbiome data containers in R/Bioconductor for the melt
operation.

The tests utilize the following publicly available data sets. We thank
the original authors for making these valuable data resources openly
available. Check the links for details and original references:

-   [hitchip1006](https://github.com/microbiome/miaTime/blob/master/R/data.R)
    (Lahti et al. 2014)
-   [SongQAData](https://microbiome.github.io/microbiomeDataSets/reference/SongQAData.html)
    Song et al. (2016)
-   [GrieneisenTSData](https://microbiome.github.io/microbiomeDataSets/reference/GrieneisenTSData.html)
    Grieneisen et al. (2021) baboon data set

Data characteristics
--------------------

Full sample sizes by data set:

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Dataset</th>
<th style="text-align: right;">N</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">AsnicarF_2021</td>
<td style="text-align: right;">1098</td>
</tr>
<tr class="even">
<td style="text-align: left;">SongQAData</td>
<td style="text-align: right;">1522</td>
</tr>
<tr class="odd">
<td style="text-align: left;">GrieneisenTSData</td>
<td style="text-align: right;">16234</td>
</tr>
</tbody>
</table>

Feature counts by data set:

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Rank</th>
<th style="text-align: right;">AsnicarF_2021</th>
<th style="text-align: right;">SongQAData</th>
<th style="text-align: right;">GrieneisenTSData</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Phylum</td>
<td style="text-align: right;">16</td>
<td style="text-align: right;">39</td>
<td style="text-align: right;">12</td>
</tr>
<tr class="even">
<td style="text-align: left;">Class</td>
<td style="text-align: right;">23</td>
<td style="text-align: right;">92</td>
<td style="text-align: right;">18</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Order</td>
<td style="text-align: right;">40</td>
<td style="text-align: right;">167</td>
<td style="text-align: right;">24</td>
</tr>
<tr class="even">
<td style="text-align: left;">Family</td>
<td style="text-align: right;">74</td>
<td style="text-align: right;">271</td>
<td style="text-align: right;">40</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Genus</td>
<td style="text-align: right;">205</td>
<td style="text-align: right;">583</td>
<td style="text-align: right;">92</td>
</tr>
<tr class="even">
<td style="text-align: left;">Species</td>
<td style="text-align: right;">633</td>
<td style="text-align: right;">375</td>
<td style="text-align: right;">0</td>
</tr>
</tbody>
</table>

Relative differences in execution time by sample size
-----------------------------------------------------

![](figs/melt_first_ratio.png)

![](figs/melt_second_ratio.png)

Absolute execution time by sample size
--------------------------------------

![](figs/melt_abs_by_time.png)

Execution times vs number of features
-------------------------------------

![](figs/melt_multi_ex_time.png)
