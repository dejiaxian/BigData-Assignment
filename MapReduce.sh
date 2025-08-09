# Step 1: Switch to the Hadoop user to gain necessary permissions for Hadoop administration tasks
sudo su - hadoop

# Step 2: Start all Hadoop services to ensure the system is fully operational
start-all.sh

# Step 3: Create workspace and change directory to that specific workspace
mkdir -p ~/workspace
cd ~/workspace

# Step 4: Download the CSV file from your S3 bucket
aws s3 cp s3://bigdata-assignment/reviews-1230-2345.csv . 

# Step 5: Upload the CSV file to HDFS
hadoop fs -mkdir -p /user/hadoop/reviews
hadoop fs -put -f reviews-1230-2345.csv /user/hadoop/reviews/

# Step 6: Verify that the CSV file can be accessed in HDFS
hadoop fs -ls /user/hadoop/reviews

# Step 7: Create the mapper and reducer script for text analysis and make it executable
# Scripts are available at mapper.py and reducer.py
mkdir -p ~/workspace/python
cd ~/workspace/python
nano mapper.py 
nano reducer.py
chmod +x mapper.py reducer.py

# Step 8: Run the word-count MapReduce
# Output directory must not already exist
hadoop fs -rm -r -f /user/hadoop/reviews_wc

hadoop jar \
  /home/hadoop/hadoop-3.2.2/share/hadoop/tools/lib/hadoop-streaming-3.2.2.jar \
  -input /user/hadoop/reviews/reviews-1230-2345.csv \
  -output /user/hadoop/reviews_wc \
  -file mapper.py -file reducer.py \
  -mapper mapper.py \
  -reducer reducer.py

# Step 9: Text Analysis - output the top 20 keywords
# Bring the result locally, then sort by count descending and show top 20
hadoop fs -getmerge /user/hadoop/reviews_wc/part-* ~/workspace/reviews_counts.txt
sort -k2 -nr ~/workspace/reviews_counts.txt | head -n 20

# Step 10: Create the mapper and reducer script for sentiment analysis and make it executable
nano mapper_sentiment.py
nano reducer_sentiment.py
chmod +x mapper_sentiment.py reducer_sentiment.py

# Step 11: Run the Hadoop-Streaming job
hadoop fs -rm -r -f /user/hadoop/sentiment_out

hadoop jar /home/hadoop/hadoop-3.2.2/share/hadoop/tools/lib/hadoop-streaming-3.2.2.jar \
  -files mapper_sentiment.py,reducer_sentiment.py \
  -mapper mapper_sentiment.py \
  -reducer reducer_sentiment.py \
  -input  /user/hadoop/reviews/reviews-1230-2345.csv \
  -output /user/hadoop/sentiment_out

# Step 12: Pull the results for sentiment analysis locally
hadoop fs -getmerge /user/hadoop/sentiment_out/part-* ~/workspace/sentiment_all.tsv

# Step 13: Sentiment Analysis - summary of sentiment labels
hadoop fs -cat /user/hadoop/sentiment_out/part-* \
  | awk -F'\t' '$1=="SENT"{cnt[tolower($2)]+=$3} END{for(s in cnt) print s"\t"cnt[s]}' \
  | sort -k2 -nr \
  | awk 'BEGIN{print "sentiment_label"} { label=$1; cnt=$2; label = toupper(substr(label,1,1)) tolower(substr(label,2)); printf("%d:\t%-10s %10d\n", NR, label, cnt) }'

# Step 14: Sentiment Analysis - output the top 20 positive keywords
hadoop fs -cat /user/hadoop/sentiment_out/part-* \
  | awk -F'\t' '$1=="TOK" && tolower($2)=="positive"{ if(length($3)>0) cnt[$3]+=($4+0) } END{for(w in cnt) print w"\t"cnt[w]}' \
  | sort -k2,2nr \
  | head -n 20 \
  | awk 'BEGIN{print "Top 20 Positive Keywords:"; print "      word       n"} {printf("%d:  %-10s %d\n", NR, $1, $2)}'

# Step 15: Sentiment Analysis - output the top 20 negative keywords
hadoop fs -cat /user/hadoop/sentiment_out/part-* \
  | awk -F'\t' '$1=="TOK" && tolower($2)=="negative"{ if(length($3)>0) cnt[$3]+=($4+0) } END{for(w in cnt) print w"\t"cnt[w]}' \
  | sort -k2,2nr \
  | head -n 20 \
  | awk 'BEGIN{print "Top 20 Negative Keywords:"; print "      word       n"} {printf("%d:  %-10s %d\n", NR, $1, $2)}'

# Step 16: Sentiment Analysis - output the top 20 neutral keywords
hadoop fs -cat /user/hadoop/sentiment_out/part-* \
  | awk -F'\t' '$1=="TOK" && tolower($2)=="neutral"{ if(length($3)>0) cnt[$3]+=($4+0) } END{for(w in cnt) print w"\t"cnt[w]}' \
  | sort -k2,2nr \
  | head -n 20 \
  | awk 'BEGIN{print "Top 20 Neutral Keywords:"; print "      word       n"} {printf("%d:  %-10s %d\n", NR, $1, $2)}'

