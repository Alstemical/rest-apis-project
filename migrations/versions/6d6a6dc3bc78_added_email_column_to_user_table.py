"""Add email column to users table

Revision ID: [your_revision_id]
Revises: [your_previous_revision_id]
Create Date: [your_create_date]

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '[your_revision_id]'
down_revision = '[your_previous_revision_id]'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands manually written by you ###
    op.add_column('users', sa.Column('email', sa.String(length=256), nullable=False))
    op.create_unique_constraint("uq_users_email", "users", ["email"])
    # ### end Alembic commands ###


def downgrade():
    # ### commands manually written by you ###
    with op.batch_alter_table('users', schema=None) as batch_op:
        batch_op.drop_constraint("uq_users_email", type_='unique')
        batch_op.drop_column('email')
    # ### end Alembic commands ###