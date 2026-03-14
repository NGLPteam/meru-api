# frozen_string_literal: true

# Remove a number of unused functions from the early days of Meru experimentation
# and get things ready for Postgres 18.
#
# There's a logic error in the `>` operator for variable precision dates, commutator and negator are swapped.
class CleanUpDatabase < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
    DROP AGGREGATE IF EXISTS jsonb_bool_or(boolean, text[]);

    DROP FUNCTION IF EXISTS jsonb_bool_or_rec(jsonb, boolean, text[]);

    DROP AGGREGATE IF EXISTS public.max(public.variable_precision_date);

    DROP OPERATOR IF EXISTS public.> (public.variable_precision_date, public.variable_precision_date);

    CREATE OPERATOR public.> (
      FUNCTION = public.vpdate_gt,
      LEFTARG = public.variable_precision_date,
      RIGHTARG = public.variable_precision_date,
      COMMUTATOR = OPERATOR(public.<),
      NEGATOR = OPERATOR(public.<=),
      RESTRICT = scalargtsel,
      JOIN = scalargtjoinsel
    );

    CREATE AGGREGATE public.max(public.variable_precision_date) (
        SFUNC = public.vpd_greatest,
        STYPE = public.variable_precision_date,
        FINALFUNC = public.vpdate_nullif_none,
        MSFUNC = public.vpd_greatest,
        MINVFUNC = public.vpd_least,
        MSTYPE = public.variable_precision_date,
        SORTOP = OPERATOR(public.>),
        PARALLEL = safe
    );
    SQL
  end

  def down
    # Intentionally left blank. These fixes are not intended to be rolled back.
  end
end
