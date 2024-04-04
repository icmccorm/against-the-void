# “Against the Void" - Replication Package

This repository is a replication package for the paper ['“Against the Void”: An Interview and Survey Study of How Rust Developers Use Unsafe Code.'](https://arxiv.org/abs/2404.02230) All direct (e.g. names, institutions) and indirect (positions, projects) identifying information from participants has been redacted following procedures approved by our institution's IRB. 

This repository contains the following
```
- data               
    |- interviews           // raw interview transcripts
    |- community_survey     // survey responses
    |- screening_survey     // survey responses
    |- irr                  // codes and coding decisions 
- scripts                   // R and Python scripts used to calculate IRR and to compile survey data       
```

The appendix of our paper is provided in [appendix.pdf](https://github.com/icmccorm/against-the-void/blob/main/appendix.pdf). It contains three sections. The first section includes the questions on our screening survey and our interview protocol. The second section contains the results from conducting 7 rounds of IRR, including intermediate codebooks used for each round. We used IRR as a mechanism for refining our codebook. The third section contains the full text of our community survey and response counts for each question. Recruitment materials are provided in [recruitment.pdf](https://github.com/icmccorm/against-the-void/blob/main/recruitment.pdf). This contains all emails and social media posts used throughout each stage of the investigation. 

## Building
Executing `make build` will compile our raw data into the tables and figures present in our paper and its appendix. This script requires R version 4.3.1 and Python 3. Alternatively, if you are running Docker on an x86 system, you can create an image with a build of our project by executing `docker build .` from the root directory. This image includes all necessary dependencies and builds the project automatically as its final step.

## Data
Raw data is located within the `data` directory. This contains all anonymized interview transcripts, responses to our screening and community surveys, and IRR scores.

### Interviews
```
- data
    |- interviews
        |- coding               // codebooks exported from ATLAS.ti
            |- codebook.csv     // individual codes and their definitions
            |- decisions.csv    // coding decisions
        |- transcripts          // markdown and .PDF interview transcripts exported from ATLAS.ti
```
We provide a full export of our ATLAS.ti project as well as unencoded copies of the raw interview transcripts and codebooks. 
Each participant is identified by a unique ID ranging from 1 to 19. 

### Surveys
```
- data
    |- community_survey
        |- coding
            |- unsafe_api.csv   // coded open-ended responses for WUQ1
            |- unsafe.csv       // coded open-ended responses for EUAQ1
        |- data.csv             // individual survey responses
        |- questions.csv        // mapping from question IDs to question text
        |- sections             // mapping from section IDs to section name
    |- screening_survey
        |- data.csv             // individual survey responses
        |- questions.csv        // mapping from question IDs to question text.
```
Each question in the screening and community surveys is identified by a unique ID. Questions in the community survey were grouped into sections. Each question ID contains a prefix identifying its section. For example, "WUQ1" is the 1st question in section 
"WUQ", which contains questions about participants' motivations for using unsafe code. 

### IRR
```
- data
    |- irr
        |- 1
           |- data.csv      // codes selected for each quote by each author
           |- output.md     // individual quotes coded in this sample
           |- survey.csv    // codes presented for each user to select
        |- 2
        |- ...
        |- code_mapping.csv
        |- theme_mapping.csv
```
To refine our codebook, we conducted 7 rounds of coding random samples of quotes and we calculated interrater reliability after each round. Coding decisions were made using an online form. Data for each round are contained in the [irr](https://github.com/icmccorm/against-the-void/tree/main/data/irr) directory in subdirectories numbered 1 through 7. Each subdirectory contains 3 files. The file [survey.csv](https://github.com/icmccorm/against-the-void/blob/main/data/irr/1/survey.csv) contains the codes presented by the form for each coder to select during that round, while [data.csv](https://github.com/icmccorm/against-the-void/blob/main/data/irr/1/data.csv) contains the selections made by each coder for each quote in [output.md](https://github.com/icmccorm/against-the-void/blob/main/data/irr/1/output.md).

## Coauthors
* [Tomas Dougan](https://github.com/taurreco)
* [Sam Estep](https://samestep.com/)
* [Hanan Hibshi](https://www.cs.cmu.edu/~hhibshi/)
* [Jonathan Aldrich](https://www.cs.cmu.edu/~aldrich/)
* [Joshua Sunshine](https://www.cs.cmu.edu/~jssunshi/)
