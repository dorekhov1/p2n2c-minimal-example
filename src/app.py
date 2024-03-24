from opentelemetry.instrumentation.langchain import LangchainInstrumentor


def run():
    LangchainInstrumentor().instrument()
