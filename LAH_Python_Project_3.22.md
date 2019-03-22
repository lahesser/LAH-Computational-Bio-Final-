
## Computational Biology: Using Python for Data Parsing and Visualization 

### L. Ande Hesser

The work in our lab in part studies the triangular relation of lifestyle, microbiome, and immune disease. This often results in the need to examine large sets of data produced by other groups to find relevant subsets. The goal of this part of my project is to extract information from demographic metadata of two IBD cohorts: an ulcerative colitis (UC) cohort and Crohn's Disease (CD) cohort. I want to know if there's any relationship between BMI, gender, and whether their bowel was actively inflamed at the time of diagnosis. To do this I will create dictionaries counting the occurences in each of these categories and calculate frequencies from these dictionaries. I will then convert the data into a dataframe using pandas, allowing simple visualization. While this code is specific to this dataset, I will be able to use this general outline with many different data sets with little adjustment. This code automates the process of sifting through data, grouping by desired variables, and graphing the output. 

This data was obtained from a biopsies collected from Bern gastroenterology clinics and was published by Yilmaz et al in 2019 in Nature Medicine ("Microbial network disturbances in relapsing refractory Crohn's disease"). The publication includes a full link to the raw metadata.
https://www.nature.com/articles/s41591-018-0308-z#Abs1 



```python
%pdb
import re 
import csv
```

    Automatic pdb calling has been turned ON


### Part I: Loading and Reading the Data 

First, I will load the text file with a dictionary reader. This initial, simple function will import the file and count the number of inflamed or not inflamed individuals for whichever demographic information the user specifies (we will use gender and BMI).


```python
def get_inflammation_stats(demographics): 
  
    Inflammation = {}
    with open('../Downloads/Cohort2_mappingfile.txt') as f: 
        dr = csv.DictReader(f, delimiter = '\t')
        for row in dr:
            matching = True
            for i in demographics:
                    if row[i] != demographics[i]: 
                        matching = False
                        break 
            if matching == True: 
                my_inflam = row['s']
                Inflammation[my_inflam] = Inflammation.get(my_inflam, 0) + 1
    return(Inflammation)
```


```python
#check that it works. I want it to return the number of Inflamed and Non-Inflamed for this demographic 
get_inflammation_stats({'Gender': 'F', 'BMI_categorized': 'Normal'})
```




    {'Non_Inflamed': 56, 'Inflamed': 14}



Now I will create lists of Gender, BMI category, disease type, and Inflammation status. We want a value for Gender and Inflammation status for every individual, but we only want the 3 BMI categories so I input these manually. I then verify that we have a value for each individual in the list, i.e. each list has the same number of inputs.


```python
Gender = []
BMI_category = ['Normal', 'Overweight', 'Obese']
Inflammation_status = []
Disease = []
with open('../Downloads/Cohort2_mappingfile.txt') as f: 
    dr = csv.DictReader(f, delimiter = '\t')
    for row in dr: 
        Gender.append(row['Gender'])
        Inflammation_status.append(row['s'])
        Disease.append(row['Disease'])
```


```python
print(len(Gender))
print(len(Inflammation_status))
print(len(Disease))
```

    1217
    1217
    1217


### Part II: Defining Functions and Making Calculations 

Next, we want to write a function to perform the above function for each demographic, so that we don't have to manually count for each gender, BMI type, and disease. This is a series of three nested dictionaries, each of which must be defined in turn. Note while this is a function and you would ideally be able to input any category, the 'BMI_categorized' category is built into the function, so it will need to be changed before evaluating any other category. The reason this is nested in the function is because the 'BMI_categorized' label must match exactly that from the data, while I named the category myself. 


```python
#we want to find the number of inflamed / not inflamed individuals in each demographic group. 

#desired output: {UC: {Males: {Normal: {Inflamed:#, Noninflamed: #}, 
#                              Overweight: {Inflamed:#, Noninflamed: #}, 
#                              Obese: {Inflamed:#, Noninflamed: #}}, 
#                      Females: etc. }

def get_all_categories_diseases(category): 
    
    categorized_inflammation_by_disease = {}
    Genders = ['M', 'F']
    disease_types = ["UC", "CD"]
    
    for disease in list(disease_types): 
        categorized_inflammation_by_disease[disease] = {}
        for gender in list(Genders): 
            categorized_inflammation_by_disease[disease][gender] = {}
            for i in list(category): 
                categorized_inflammation_by_disease[disease][gender][i] = get_inflammation_stats({'Disease': disease, 
                                                                                       'Gender': gender, 
                                                                                       'BMI_categorized': i})
    return(categorized_inflammation_by_disease)
```


```python
categorized_inflammation_by_disease = get_all_categories_diseases(BMI_category)
print(categorized_inflammation_by_disease)
```

    {'UC': {'M': {'Normal': {'Non_Inflamed': 22, 'Inflamed': 10, 'Unknown': 1}, 'Overweight': {'Non_Inflamed': 29, 'Inflamed': 9}, 'Obese': {'Non_Inflamed': 14, 'Inflamed': 2}}, 'F': {'Normal': {'Non_Inflamed': 17, 'Inflamed': 6}, 'Overweight': {'Non_Inflamed': 11, 'Inflamed': 3}, 'Obese': {'Non_Inflamed': 6}}}, 'CD': {'M': {'Normal': {'Non_Inflamed': 38, 'Inflamed': 7}, 'Overweight': {'Non_Inflamed': 28, 'Inflamed': 7}, 'Obese': {'Inflamed': 3, 'Non_Inflamed': 2}}, 'F': {'Normal': {'Non_Inflamed': 33, 'Inflamed': 8}, 'Overweight': {'Non_Inflamed': 6}, 'Obese': {'Non_Inflamed': 12, 'Inflamed': 2}}}}


We have now obtained a full dictionary of the number of inflamed and noninflamed individuals in each cohort. However, this dictionary is quite messy. Instead we want the proportion of inflamed individuals (inflamed / total). Note that if there were no individuals in a certain group, rather than stating "Inflamed = 0", the code will exclude that key altogether. For this reason we had to redefine and update the dictionary above to ensure that all groups were given a value. Again, we need to use a series of nested for loops to run the code for each disease, gender, and BMI category. This will again result in a nested dictionary, this time including the percentage of individuals whose tissue was inflamed at the time of biopsy. 


```python
disease_types = ["UC", "CD"]
Genders = ['M', 'F']           #these lists had been defined previously, but only within a function
categorized_inflammation_by_disease = {
    'UC': {'M': {'Normal': {'Non_Inflamed': 22, 'Inflamed': 10, 'Unknown': 1},
   'Overweight': {'Non_Inflamed': 29, 'Inflamed': 9},
   'Obese': {'Non_Inflamed': 14, 'Inflamed': 2}},
  'F': {'Normal': {'Non_Inflamed': 17, 'Inflamed': 6},
   'Overweight': {'Non_Inflamed': 11, 'Inflamed': 3},
   'Obese': {'Non_Inflamed': 6, 'Inflamed': 0}}},           #must manually add Inflamed = 0
 'CD': {'M': {'Normal': {'Non_Inflamed': 38, 'Inflamed': 7},
   'Overweight': {'Non_Inflamed': 28, 'Inflamed': 7},
   'Obese': {'Inflamed': 3, 'Non_Inflamed': 2}},
  'F': {'Normal': {'Non_Inflamed': 33, 'Inflamed': 8},
   'Overweight': {'Non_Inflamed': 6, 'Inflamed': 0},
   'Obese': {'Non_Inflamed': 12, 'Inflamed': 2}}}}


Inflam_prop_by_disease = {}
for disease in list(disease_types): 
    Inflam_prop_by_disease[disease] = {}
    for gender in list(Genders): 
        Inflam_prop_by_disease[disease][gender] = {}
        for BMI in list(BMI_category): 
            Inflam_prop_by_disease[disease][gender][BMI] = round(categorized_inflammation_by_disease[disease][gender][BMI]['Inflamed'] / 
                                                (categorized_inflammation_by_disease[disease][gender][BMI]['Inflamed'] + 
                                                 categorized_inflammation_by_disease[disease][gender][BMI]['Non_Inflamed']), 
                                                    3) * 100 
print(Inflam_prop_by_disease)
print('No inflamed control subjects; frequency is zero for all groups')
```

    {'UC': {'M': {'Normal': 31.2, 'Overweight': 23.7, 'Obese': 12.5}, 'F': {'Normal': 26.1, 'Overweight': 21.4, 'Obese': 0.0}}, 'CD': {'M': {'Normal': 15.6, 'Overweight': 20.0, 'Obese': 60.0}, 'F': {'Normal': 19.5, 'Overweight': 0.0, 'Obese': 14.299999999999999}}}
    No inflamed control subjects; frequency is zero for all groups


### Part III: Visualization

Finally we can begin to graph now that we have useable data. Since there are no inflamed control subjects, I only want to focus on the Ulcerative Colitis and Crohn's disease patients. I separate them into two different dictionaries so that it is easier to read and paste into a dataframe. Using pandas, we can concatenate these two dictionaries into a dataframe. This changes the data format from dictionaries to a succinct table of values. This table can then easily be plotted, again using the pandas dataframe and we can visualize our findings. It appears that with increasing BMI less males with UC are inflamed, whereas this trend is the opposite for males with CD. It is difficult to make any conclusions about the females from either group, because they are incomplete groups. 


```python
#graph our data for inflammation proportion of different cohorts. We need to turn the dictionary 
#into a Data Frame so that the pandas can read it. 

import pandas as pd 

categorized_inflammation_UC = {'Males': {'Normal': 31.2, 'Overweight': 23.7, 'Obese': 12.5}, 
                               'Females': {'Normal': 26.1, 'Overweight': 21.4, 'Obese': 0.0}}
categorized_inflammation_CD = {'Males': {'Normal': 15.6, 'Overweight': 20.0, 'Obese': 60.0}, 
                               'Females': {'Normal': 19.5, 'Overweight': 0.0, 'Obese': 14.3}}

df = pd.concat({"CD": pd.DataFrame(categorized_inflammation_CD), 
                        "UC": pd.DataFrame(categorized_inflammation_UC)}).unstack(0)
```


```python
df
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead tr th {
        text-align: left;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr>
      <th></th>
      <th colspan="2" halign="left">Males</th>
      <th colspan="2" halign="left">Females</th>
    </tr>
    <tr>
      <th></th>
      <th>CD</th>
      <th>UC</th>
      <th>CD</th>
      <th>UC</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>Normal</th>
      <td>15.6</td>
      <td>31.2</td>
      <td>19.5</td>
      <td>26.1</td>
    </tr>
    <tr>
      <th>Obese</th>
      <td>60.0</td>
      <td>12.5</td>
      <td>14.3</td>
      <td>0.0</td>
    </tr>
    <tr>
      <th>Overweight</th>
      <td>20.0</td>
      <td>23.7</td>
      <td>0.0</td>
      <td>21.4</td>
    </tr>
  </tbody>
</table>
</div>




```python
#I thought the re-indexing would change the layout of the graph into more relevant BMI order but it did not. 
df.reindex(['Normal', 'Overweight', 'Obese'])
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead tr th {
        text-align: left;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr>
      <th></th>
      <th colspan="2" halign="left">Males</th>
      <th colspan="2" halign="left">Females</th>
    </tr>
    <tr>
      <th></th>
      <th>CD</th>
      <th>UC</th>
      <th>CD</th>
      <th>UC</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>Normal</th>
      <td>15.6</td>
      <td>31.2</td>
      <td>19.5</td>
      <td>26.1</td>
    </tr>
    <tr>
      <th>Overweight</th>
      <td>20.0</td>
      <td>23.7</td>
      <td>0.0</td>
      <td>21.4</td>
    </tr>
    <tr>
      <th>Obese</th>
      <td>60.0</td>
      <td>12.5</td>
      <td>14.3</td>
      <td>0.0</td>
    </tr>
  </tbody>
</table>
</div>




```python
Inflam_plot = df.plot.bar(title = "Frequency of Inflammation in Two IBD Conditions",  
                     color = ['blue', 'navy', 'red', 'maroon'])
Inflam_plot.set_xlabel('BMI', fontsize = 14)
Inflam_plot.set_ylabel('Individuals Inflamed at Diagnosis (%)')
```




    Text(0, 0.5, 'Individuals Inflamed at Diagnosis (%)')




![png](output_17_1.png)



```python

```
