UPDATE twofer
SET response = CASE 
    WHEN input IS NULL OR input = '' THEN 'One for you, one for me.'
    ELSE 'One for ' || input || ', one for me.'
END;
