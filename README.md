# BigData-Assignment
IST3134 Big Data Analytics for the Cloud | Group Assignment (20%)

# Background
This project explores Big Data Analytics in the cloud by implementing and evaluating two different approaches to processing a large dataset: one using the MapReduce framework in a distributed environment (e.g., Hadoop) and another using a non-MapReduce method. The goal is to highlight how each approach handles scalability, parallelism, and performance when working with large-scale data.

The work involves selecting a suitable dataset, implementing comparable algorithms in both approaches, and analyzing their outputs to understand trade-offs in efficiency, complexity, and resource usage. The comparison provides insights into when MapReduce is most beneficial versus when alternative methods may be preferable.

The dataset used in this assignment is the Steam Reviews Dataset by forgemaster on Kaggle: https://www.kaggle.com/datasets/forgemaster/steam-reviews-dataset

# Objectives
1. Implement a MapReduce algorithm to process and analyze a large dataset in a cloud-based distributed environment.
2. Develop an equivalent non-MapReduce implementation for the same problem.
3. Compare both approaches in terms of execution time, scalability, complexity, and ease of implementation.
4. Analyze the results to identify strengths and limitations of each method.
5. Reflect on the practical considerations of choosing between MapReduce and alternative processing techniques for Big Data tasks.

# MapReduce Solution
The Hadoop-based solution that employs the MapReduce algorithm runs on a cluster of AWS EC2 instances, where it is configured with 1 master node and 2 slave nodes. This solution can be accessed at the "MapReduce_Approach" folder, then follow the instructions in the "MapReduce.sh" file and run the commands line by line.

# Non-MapReduce Solution

