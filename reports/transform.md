Overview
--------

This report contains benchmarking results for the transform operation
with common microbiome data containers in R/Bioconductor for the
transform operation.

The tests utilize the following publicly available data sets. We thank
the original authors for making these valuable data resources openly
available. Check the links for details and original references:

-   [SongQAData](https://microbiome.github.io/microbiomeDataSets/reference/SongQAData.html)
    Song et al. (2016)
-   HMP\_2019\_ibdmdb (([source
    1](https://pubmed.ncbi.nlm.nih.gov/29311644/), [source
    2](https://pubmed.ncbi.nlm.nih.gov/31142855/))
-   [ShaoY\_2019](https://pubmed.ncbi.nlm.nih.gov/31534227/)

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
<td style="text-align: left;">SongQAData</td>
<td style="text-align: right;">1522</td>
</tr>
<tr class="even">
<td style="text-align: left;">HMP_2019_ibdmdb</td>
<td style="text-align: right;">1627</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ShaoY_2019</td>
<td style="text-align: right;">1644</td>
</tr>
</tbody>
</table>

Feature counts by data set:

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Rank</th>
<th style="text-align: right;">SongQAData</th>
<th style="text-align: right;">HMP_2019_ibdmdb</th>
<th style="text-align: right;">ShaoY_2019</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Phylum</td>
<td style="text-align: right;">39</td>
<td style="text-align: right;">15</td>
<td style="text-align: right;">14</td>
</tr>
<tr class="even">
<td style="text-align: left;">Family</td>
<td style="text-align: right;">271</td>
<td style="text-align: right;">69</td>
<td style="text-align: right;">90</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Species</td>
<td style="text-align: right;">374</td>
<td style="text-align: right;">579</td>
<td style="text-align: right;">819</td>
</tr>
</tbody>
</table>

Relative differences in execution time by sample size
-----------------------------------------------------

![](../reports/figs/transform_first_ratio-1.png)

Absolute execution time by sample size
--------------------------------------

![](../reports/figs/transform_abs_by_time-1.png)

Execution times vs number of features
-------------------------------------

![](../reports/figs/transform_multi_ex_time-1.png)
