# 02_analysis

This directory contains work done by [Junseo Park](http://www.github.com/junseo-park) for analysis on tweets from Bogota and Buenos Aires.

## Structure

All notebooks can be found in the [`notebooks`](./notebooks) subdirectory. Specifically:

- [Textual analysis of La L/El Bronx](./notebooks/bogota_LaL_ElBronx.ipynb)
- Home location analysis of Buenos Aires tweets
	- [2012](./notebooks/ba_2012.ipynb)
	- [2013](./notebooks/ba_2013.ipynb)
	- [2014](./notebooks/ba_2014.ipynb)
	- [2015](./notebooks/ba_2015.ipynb)
- Home location analysis of Bogota tweets
	- [2012](./notebooks/bo_2012.ipynb)
	- [2013](./notebooks/bo_2013.ipynb)
	- [2014](./notebooks/bo_2014.ipynb)
	- [2015](./notebooks/bo_2015.ipynb)
- [Process of creating home location identification methodology](./methodology_home_location_identification.ipynb)

If any of the notebooks do not load, copy the URL and paste it into the form on www.nbviewer.com.

Many of the notebooks use scripts that can be found in the [`scripts`](./scripts) subdirectory; this directory also contains a copy of the R script [`home_geography.R`](./scripts/home_geography.R) created by [Ate Poorthuis](https://github.com/atepoorthuis), which was referenced to port the same methodology to Python [`home_location.py`](./scripts/home_location.py).

## Setup

### Data

We have not uploaded any data to this Github repository due to file size restrictions; this is being executed using the [`.gitignore`](../.gitignore) at the root directory. To replicate any results found in this project, please contact [Junseo](mailto:junseopark@berkeley.edu) for the data, which can then be placed in this directory in the following file structure:

```
02_analysis/data
├── shapefiles
│   ├── bogota_neighborhood_shapefiles
│   │   ├── (redacted for brevity)
│   ├── bogota_shapefiles
│   │   ├── (redacted for brevity)
│   └── buenos_aires_shapefiles
|   │   ├── (redacted for brevity)
└── tweets
    ├── ba_2012.csv
    ├── ba_2013.csv
    ├── ba_2014.csv
    ├── ba_2015.csv
    ├── bo_2012.csv
    ├── bo_2013.csv
    ├── bo_2014.csv
    └── bo_2015.csv
```

### Python environment

We have included a [`requirements.txt`](./requirements.txt) that can be used to initialize a Python virtual environment. This can be executed by running the following commands in sequence on the terminal (applicable for Python 3.4 and above):

```bash
python3 -m venv .env             # Create a virtual environment in the .env directory
source .env/bin/activate         # Activate the virtual environment
pip install -r requirements.txt  # Replicate virtual environment from requirements.txt
```

Once the setup is initialized once, the same virtual environment can be reactivated in the future using the command `source .env/bin/activate`.


### Computing requirements

The tweets and shapefiles are large in size, and thus challenging for many personal computers to hold in memory. These computations were performed on Berkeley's EML servers; we expect that a personal computer with 8gb of RAM may be able to replicate analyses on one set of tweets at a time, but with longer runtime due to computational power. If possible, we recommend using cloud compute services or a dedicated server for computation.
