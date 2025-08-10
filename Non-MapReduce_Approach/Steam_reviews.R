# Step 1: Load required libraries
library(data.table)
library(tidyverse)
library(tidytext)
library(wordcloud)
library(SentimentAnalysis)
library(tm)

# Step 2: Load the specified CSV file
file_path <- "C:/Users/Wong/Downloads/SteamReviews/reviews-1230-2345.csv"
reviews_raw <- fread(file_path, colClasses = "character")

# Step 3: Keep only 'review' column and remove NAs
reviews <- reviews_raw %>%
  select(review) %>%
  filter(!is.na(review))

# Step 4: Keyword analysis (top words)
data("stop_words")
top_words <- reviews %>%
  unnest_tokens(word, review) %>%
  anti_join(stop_words, by = "word") %>%
  count(word, sort = TRUE)

print(head(top_words, 20))

# Step 5: Word cloud
set.seed(123)
wordcloud(words = top_words$word, freq = top_words$n, min.freq = 10,
          max.words = 100, random.order = FALSE, scale = c(3, 0.5))

# Step 6: Function for sentiment analysis on a batch
process_batch <- function(text_batch) {
  corpus <- Corpus(VectorSource(text_batch))
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, stripWhitespace)
  sentiment_result <- analyzeSentiment(corpus)
  return(sentiment_result$SentimentQDAP)
}

# Step 7: Batch processing
batch_size <- 2000  # Number of reviews per batch
n <- nrow(reviews)
sentiments <- numeric(n)

for (i in seq(1, n, by = batch_size)) {
  end_index <- min(i + batch_size - 1, n)
  cat("Processing reviews", i, "to", end_index, "...\n")
  sentiments[i:end_index] <- process_batch(reviews$review[i:end_index])
}

# Step 8: Store sentiment scores
reviews$sentiment <- sentiments

# Step 9: Categorise sentiment
reviews$sentiment_label <- case_when(
  reviews$sentiment > 0 ~ "Positive",
  reviews$sentiment < 0 ~ "Negative",
  TRUE ~ "Neutral"
)

# Step 10: Sentiment summary
sentiment_summary <- reviews %>%
  count(sentiment_label) %>%
  arrange(desc(n))
print(sentiment_summary)

# Step 11: Pie chart with percentage labels
sentiment_summary <- reviews %>%
  count(sentiment_label) %>%
  mutate(percentage = n / sum(n) * 100) %>%
  arrange(desc(n))

ggplot(sentiment_summary, aes(x = "", y = n, fill = sentiment_label)) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  geom_text(aes(label = paste0(round(percentage, 1), "%")),
            position = position_stack(vjust = 0.5), color = "white", size = 5) +
  labs(title = " Review Sentiment Distribution", x = NULL, y = NULL, fill = "Sentiment") +
  theme_void()

# Step 12: Top keywords for each sentiment category
data("stop_words")
get_top_words <- function(df, sentiment_name, top_n = 20) {
  df %>%
    filter(sentiment_label == sentiment_name) %>%
    unnest_tokens(word, review) %>%
    anti_join(stop_words, by = "word") %>%
    count(word, sort = TRUE) %>%
    slice_head(n = top_n)
}

top_positive <- get_top_words(reviews, "Positive")
top_negative <- get_top_words(reviews, "Negative")
top_neutral  <- get_top_words(reviews, "Neutral")

cat("\nTop Positive Keywords:\n")
print(top_positive)
cat("\nTop Negative Keywords:\n")
print(top_negative)
cat("\nTop Neutral Keywords:\n")
print(top_neutral)

# Step 13: Save output
fwrite(reviews, "reviews_1230_2345_with_sentiment.csv")
