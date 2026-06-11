# ITF Transport Data, Statistics and Modelling Workshop for Ukrainian Transport Planners

Built by the International Transport Forum ([ITF](itf-oecd.org)) under the framework of the Common Interest Group for Transport in Ukraine ([CIG4U](https://www.itf-oecd.org/common-interest-group-transport-ukraine)). 

This repository enables open-source urban transport analysis using Python and free data. It contains two hands-on exercises that take you from mapping infrastructure coverage to estimating city-wide traffic flows using only OpenStreetMap and WorldPop. Built for transport planners, no coding experience required.

---

## Exercises

### Exercise 1 — Infrastructure Coverage Analysis
Map a city's transport network, estimate infrastructure availability per person, and identify underserved areas using OpenStreetMap and WorldPop population data.

### Exercise 2 — Demand Estimation and Traffic Assignment
Build an origin-destination demand matrix using a gravity model, assign estimated trips to the road network, and develop evidence-based policy recommendations.

---

## Getting Started

Both exercises run in **Google Colab** — no local installation needed.

1. Click the link for the exercise you want to open
2. Sign in to a Google account if prompted
3. Go to **File → Save a copy in Drive** before making any changes
4. Run each cell in order, waiting for **"Complete"** before moving on

### Run in a dev container

You can also open this repo in a pre-configured environment with all dependencies installed using GitHub Codespaces or a local dev container:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Robinlovelace/itfworkshop?quickstart=1)

### Rendered website

A Quarto website version of the exercises is available at:

**[robinlovelace.net/itfworkshop](https://robinlovelace.net/itfworkshop/)**

### Local development with pixi

To set up a local environment with all Python dependencies:

```bash
# Install pixi (if not already installed)
curl -fsSL https://pixi.sh/install.sh | bash

# Clone and set up
git clone https://github.com/Robinlovelace/itfworkshop.git
cd itfworkshop
pixi install

# Render the Ukrainian refugee flows page
pixi run render

# Or start a live preview
pixi run start

# Sync requirements.txt if dependencies in pixi.toml change
pixi run sync-reqs
```

Dependencies are managed in [pixi.toml](pixi.toml) (see [Pixi dependencies documentation](https://pixi.sh/latest/features/dependencies/)). The `sync-reqs` task (see [Pixi tasks documentation](https://pixi.sh/latest/features/tasks/)) regenerates [requirements.txt](requirements.txt) to keep containerized environments updated without manual duplication.

---

## Data Sources

| Dataset | Description | Licence |
|---|---|---|
| [OpenStreetMap](https://www.openstreetmap.org/) | Road network, points of interest | ODbL |
| [WorldPop](https://www.worldpop.org/) | Gridded population estimates | CC BY 4.0 |

---

## Requirements

No coding experience is required. The notebooks are self-contained and all code is pre-written. A Google account is needed to run exercises in Colab.

---

## Context

These exercises were developed for an ITF workshop for Ukrainian transport planners, officials and academics, held in Kyiv on 12 June 2026. While the exercises are designed for Ukrainian cities, the methodology is general and can be adapted to any city with OpenStreetMap coverage.
