CREATE TABLE if not exists categories (
    id int NOT NULL,
    category varchar(32) NOT NULL,
    priority int,
    en varchar(32) NOT NULL,
    en_pr varchar(32) NOT NULL,
    it varchar(32),
    it_pr varchar(32),
    PRIMARY KEY (category)
)