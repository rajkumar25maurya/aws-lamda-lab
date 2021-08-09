resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
  depends_on = ["aws_iam_role.iam_for_lamda","aws_iam_policy.lambda_logging"]
}

resource "aws_lambda_function" "lambda_tf" {
    filename    =   "lambda.zio"
    function_name = "lambda_handler"
    role = $"{aws_iam_role.iam_for_lambda.arn}"
    handler         = "lambda.lambda_handler"
    runtime         = "python3.7"
    source_code_hash = "${filebase64sha256("lambda.zip")}"
    depends_on      =   ["aws_iam_role.iam_for_lambda"]

  
}