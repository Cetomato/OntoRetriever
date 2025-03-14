On a Linux computer with at least 32GB of physical memory and an Nvidia graphics card with at least 16GB of VRAM, install the Nvidia drivers.

Start Ollama (test on version 0.3.9) server , install llama3.1:8B model, stop proxy.

In R:

install.packages("reticulate")

reticulate::virtualenv_install("r-reticulate", packages = c("faiss", "numpy", "ollama", "requests", "pikle"))

install.packages("remotes")

remotes::install_github("Cetomato/OntoRetriever")

library(OntoRetriever)

re = retrieve_similar_terms("irritability", onto ="HPO", k = 3)
print(re)
```r
#>           ID               Name    Distance
#> 1 HP:0000737       Irritability   0.0014415
#> 2 HP:0033628 Bowel irritability 125.8558502
#> 3 HP:0031588   Unhappy demeanor 130.1786652
```

re = retrieve_similar_terms("irritability", onto ="OAE", k = 3)
print(re)
```r
#>            ID                     Name     Distance
#> 1 OAE:0001105          irritability AE  0.001492374
#> 2 OAE:0002275 constant irritability AE 60.299339294
#> 3 OAE:0002025     hyperirritability AE 72.958854675
```

retrieve_similar_terms("tired", onto ="HPO", k = 3)
```r
#>           ID       Name  Distance
#> 1 HP:0012378    Fatigue  90.20061
#> 2 HP:0002329 Drowsiness 126.78558
#> 3 HP:0001254   Lethargy 127.09422
```

retrieve_similar_terms("swelling at the injection site", onto ="OAE", k = 3)
```r
#>            ID                             Name Distance
#> 1 OAE:0004526       Injection site swelling AE 14.47905
#> 2 OAE:0006820 injection site joint swelling AE 47.37137
#> 3 OAE:0006827          injection site edema AE 65.67982
```
re = map_text_to_hpo("The most commonly reported reactions were pain at the injection site and headache.", k = 3)
print(re)
```r
#>       word         ID                Name     Distance
#> 1     pain HP:0012531                Pain 1.434482e-03
#> 2     pain HP:6000684      Radiating pain 1.154257e+02
#> 3     pain HP:0025280 Pain characteristic 1.159843e+02
#> 4 headache HP:0002315            Headache 1.239755e-03
#> 5 headache HP:0002076            Migraine 9.199228e+01
#> 6 headache HP:0012459     Hypnic headache 1.037697e+02
```

ae_text = "The most commonly reported solicited local and systemic adverse reactions in pregnant
individuals (≥10%) were pain at the injection site (40.6%), headache (31.0%), muscle pain
(26.5%), and nausea (20.0%). (6.1) • The most commonly reported solicited local and systemic
adverse reactions in individuals 60 years of age and older (≥10%) were fatigue (15.5%),
headache (12.8%), pain at the injection site (10.5%), and muscle pain (10.1%). "

re = map_text_to_oae(ae_text=ae_text, k = 1)
print(re)
```r
                        word          ID                   Name     Distance
1                    fatigue OAE:0000034             fatigue AE 5.576983e-05
2                     nausea OAE:0000600              nausea AE 9.830497e-05
3                muscle pain OAE:0000383         muscle ache AE 3.491961e+01
4 pain at the injection site OAE:0000369 injection-site pain AE 2.787290e+01
5                   headache OAE:0000377            headache AE 4.732348e-05
```

