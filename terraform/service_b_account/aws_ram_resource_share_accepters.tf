resource "aws_ram_resource_share_accepter" "service_b_account_receiver_accept" {
  share_arn = var.aws_ram_resource_share_arn
}
