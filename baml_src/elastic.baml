// Data model for Generated Elastic Certified Engineer Exam Questions (ECE)
enum Category {
  QUERY_DSL @description("Query DSL: Things like match, term, range, bool,, filter, script, exists etc.")
  AGGREGATIONS @description("Aggregations: terms, histograms, pipeline, top_hits, etc.")
  SCRIPTING @description("Use of the painless scripting language.")
}

class ElasticQuestion {
  category Category @description("The category of the question")
  question string @description("The question posed in plain english that requires a person to interpret using reading comprehension at the 12th grade level.")
  endpoint string @description("The endpoint of the Elasticsearch API that the question is asking about. Use the index name as the endpoint.")
  method "GET" | "POST" | "PUT" | "DELETE" @description("Be sure to include whether the operation is a GET, POST, PUT, DELETE, etc.")
  answer string @description("The answer to the question in the form of a Elasticsearch DSL query.")
}

class ElasticSet {
  corpus ElasticQuestion @description("The questions, answers and categories in the set")
  rating "Good" | "Bad" @description("The rating of the set")
}

function GenerateElasticCertificationQuestion(subject: Category, index: string, mapping: string, data: string, context: ElasticSet[]) -> ElasticQuestion {
  // client "openai/gpt-4.1"
  client "openai/o3-mini"
  prompt #"
    {{_.role("system")}}
    You are an AI assistant trained to generated certification style questions for the Elastic Certified Engineer Exam. Your questions are targeted at the mapping provided by the user. Your goal is to create realistic and varied questions that reflect how Elastic has historially evaluated potential engineers in a proctored setting. For each question you generate, you will also generate a cognate answer that will be evaluated by an in-production Elasticsearch cluster. 

    For each question you generate: 
    1. The question should be posed in plain english that requires a person to interpret using reading comprehension at the 6th grade level.
    2. Use the mapping fields and example data as the data context. 
    3. Vary the question by the category. We are choosing this category: {{subject}}. 
    4. Assign **ONE PRIMARY CATEGORY** to each question generated consistent with the category chosen. 
    5. Provide the **question text** and the **correct answer** in the form of a JSON object
    6. Keep the syntax Elasticsearch DSL valid.
    7. Make the questions exam-level: not trivial but not impossible. Think: "can you reason through this if you were well prepared?"
    8. Provide the endpoint of the Elasticsearch API that the question is asking about. Use the index name as the endpoint. The index name is: {{index}}. 

    Format the output as a JSON object with the following schema:

    ---
    {{ctx.output_format}}
    ---

    {{_.role("assistant")}}
    {% set max_examples = 3 %}
    {% if context %}
      Here are some examples of questions and answers categorized for your convenience and context to improve the quality of your output. 
      {% for question in context[:max_examples] %}
        {% if question.rating == "Bad" %}
          Poor Example: {{question.corpus}}
        {% elif question.rating == "Good" %}
          Good Example: {{question.corpus}}
        {% endif %}
      {% endfor %}
    {% endif %}
    ---

    {{_.role("user")}}
    Here is the mapping of the index:
    {{mapping}}

    Here is some example data from the index:
    {{data}}

    {{_.role("user")}}
    Generate a question and answer pair for the {{subject}} category. 
  "#
}


test ElasticCertificationQuestion {
  functions [GenerateElasticCertificationQuestion]
  args {
    subject "QUERY_DSL"
    index "shakespeare"
    mapping #"
      {
      'mappings': {
            'properties': {
                'index': {'properties': {'_id': {'type': 'long'}, '_index': {'type': 'text', 'fields': {'keyword': {'type': 'keyword', 'ignore_above': 256}}}}},
                'line_id': {'type': 'integer'},
                'line_number': {'type': 'text', 'fields': {'keyword': {'type': 'keyword', 'ignore_above': 256}}},
                'play_name': {'type': 'keyword'},
                'speaker': {'type': 'keyword'},
                'speech_number': {'type': 'integer'},
                'text_entry': {'type': 'text', 'fields': {'keyword': {'type': 'keyword', 'ignore_above': 256}}},
                'type': {'type': 'text', 'fields': {'keyword': {'type': 'keyword', 'ignore_above': 256}}}
            }
        }
    }
    "#
    data #"
      {
    'play_name': 'Julius Caesar',
    'speech_number': 26,
    'line_number': '3.1.53',
    'text_entry': 'Is there no voice more worthy than my own',
    'speaker': 'METELLUS CIMBER',
    'type': 'line',
    'line_id': 47508
}
    "#
    context []
  }
}
