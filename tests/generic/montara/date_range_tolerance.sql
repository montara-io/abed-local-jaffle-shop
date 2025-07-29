{% test date_range_tolerance(
    model,
    column_name,
    range_type,
    after,
    before,
    tolerance
) %}
{% set whereClause = "" %}
{% if range_type == 'Before' %}
    {% set whereClause = column_name + ' >= TIMESTAMP ' + "'" + before + "'" %}
    {% elif range_type == 'After' %}
    {% set whereClause = column_name + ' < TIMESTAMP ' + "'" + after + "'" %}
{% else %}
    {% set whereClause = column_name + ' NOT BETWEEN TIMESTAMP ' + "'" + after + "'" + ' AND TIMESTAMP ' + "'" + before + "'" %}
{% endif %}

{% if tolerance == 0 %}
SELECT
    *
FROM
    {{ model }}
WHERE
    {{ whereClause }}
{% else %}
    WITH out_of_range_percentage AS (
        SELECT
            (COUNT(*) * 100.0) / (
                SELECT
                    COUNT(*)
                FROM
                    {{ model }}
            ) AS percentage
        FROM
            {{ model }}
        WHERE
            {{ whereClause }}
    )
SELECT
    *
FROM
    {{ model }}
WHERE
    {{ whereClause }}
    AND (
        SELECT
            percentage
        FROM
            out_of_range_percentage
    ) > {{ tolerance }}
{% endif %}

{% endtest %}
