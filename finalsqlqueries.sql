USE FITNESS;
#Number of trainers in each gym
SELECT g.gymname, COUNT(t.trainerid) AS NUMBER_OF_TRAINERS
FROM trainer t
INNER JOIN
gym g ON g.gymid = t.gymid
GROUP BY g.gymname
ORDER BY NUMBER_OF_TRAINERS DESC;

#Number of trainees for every trainer
SELECT t.trainerfirstname AS TRAINER_NAME,
COUNT(w.username) AS NUMBER_OF_TRAINEES
FROM trainer t
INNER JOIN
workoutroutine w ON w.trainerid = t.trainerid
GROUP BY t.trainerid
ORDER BY NUMBER_OF_TRAINEES DESC;


#New joinees
drop view latest_customers;

CREATE VIEW latest_customers AS
SELECT u.firstname, u.lastname, fms.joiningdate
FROM users u,fitnessmanagementsystem fms
WHERE u.username = fms.username
AND YEAR(fms.joiningdate) = 2020 order by fms.joiningdate desc;
SELECT * FROM latest_customers;

#Before Update Trigger ( A membership of a customer cannot be degraded)
drop trigger updatemembership;
DELIMITER //
CREATE TRIGGER updatemembership
BEFORE UPDATE
ON fitnessmanagementsystem
FOR EACH ROW
IF OLD.membershipid=(select membershipid from membership where membershiptype="platinum") THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'A Platinum customer can not be downgraded.';
END IF //
DELIMITER ;

update fitnessmanagementsystem
set membershipid=(select membershipid from membership where membershiptype="gold") where membershipid=(select membershipid from membership where membershiptype="platinum");

#Firms and their years of contribution towards our fitnessmanagementsystem
SELECT distinct firm,
CASE
    WHEN max(workexperience_years) > 4 THEN 'contributed service for more than 4 years'
    WHEN max(workexperience_years) = 4 THEN 'contributed service for 4 years'
    ELSE 'contributed service for less than 4 years'
END as description
FROM nutritionexpert group by firm;

#Number of customers for each membership type
drop procedure customers_ineach_package;
delimiter $$
create procedure customers_ineach_package (in package varchar(20)) 
begin
select m.membershiptype,count(fms.username) as CUSTOMER_COUNT from membership m,fitnessmanagementsystem fms where m.membershipid= fms.membershipid and m.membershiptype=package group by m.membershiptype;
end ;
$$
call customers_ineach_package("silver");
call customers_ineach_package("gold");
call customers_ineach_package("platinum");


          