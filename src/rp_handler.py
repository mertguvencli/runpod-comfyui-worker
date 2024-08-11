import runpod
from runpod.serverless.utils import rp_upload


def handler(job):
    job_input = job["input"]

    return job_input


if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})
