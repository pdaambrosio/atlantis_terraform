resource "aws_security_group_rule" "sg_intances_rule" {
<<<<<<< Updated upstream
  type              = var.sg_rule_type
  from_port         = var.sg_from_rule_port
  to_port           = var.sg_to_rule_port
  protocol          = var.sg_rule_protocol
  cidr_blocks       = var.sg_rule_cidr_blocks
  security_group_id = var.sg_rule_id
}
=======
  type                     = var.sg_rule_type
  from_port                = var.sg_from_rule_port
  to_port                  = var.sg_to_rule_port
  protocol                 = var.sg_rule_protocol
  cidr_blocks              = var.sg_rule_cidr_blocks
  security_group_id        = var.sg_rule_id
  source_security_group_id = var.source_security_group_id
}
>>>>>>> Stashed changes
