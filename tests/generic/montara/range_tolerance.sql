{% test range_tolerance(
    model,
    column_name,
    min=none,
    max=none,
    tolerance=0
) %}

{% set whereClause = "" %}
{% if min is not none and max is not none %}
    {% set whereClause = column_name + ' NOT BETWEEN ' + min|string + ' AND ' + max|string %}
{% elif min is not none %}
    {% set whereClause = column_name + ' < ' + min|string %}
{% elif max is not none %}
    {% set whereClause = column_name + ' > ' + max|string %}
{% else %}
    {{ exceptions.raise_compiler_error("Either 'min' or 'max' (or both) must be provided for the range_tolerance test.") }}
{% endif %}

{% if tolerance == 0 %}
SELECT *
FROM {{ model }}
WHERE {{ whereClause }}
{% else %}
    WITH out_of_range_percentage AS (
        SELECT (COUNT(*) * 100.0) / (
                SELECT COUNT(*)
                FROM {{ model }}
            ) AS percentage
        FROM {{ model }}
        WHERE {{ whereClause }}
    )
SELECT *
FROM {{ model }}
WHERE {{ whereClause }}
    AND (
        SELECT percentage
        FROM out_of_range_percentage
    ) > {{ tolerance }}
{% endif %}

{% endtest %}