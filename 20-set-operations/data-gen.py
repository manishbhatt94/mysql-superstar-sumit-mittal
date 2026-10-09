import sys


def main():
	if len(sys.argv) != 2:
		print("Insufficient CLI args. Run as:\n"
			"python data-gen.py [purchases|newsletter_subscriptions|returns]")
		return
	choice = sys.argv[1].strip().lower()
	if choice not in ["purchases", "newsletter_subscriptions", "returns"]:
		print(f"Invalid option '{choice}' received. Run as:\n"
			"python data-gen.py [purchases|newsletter_subscriptions|returns]")
		return
	print(f"Received option: [{choice}]")
	customers = customers_master()

	match choice:
		case "purchases":
			seed_purchases(customers)
		case "newsletter_subscriptions":
			seed_newsletter_subscriptions(customers)
		case "returns":
			seed_returns(customers)
		case _:
			raise ValueError("Invalid option")


def seed_purchases(custs):
	sql = "INSERT INTO purchases " \
		"(customer_id, first_name, last_name, email, purchase_date) VALUES \n"
	values = []

	pdates = [
		'2024-07-05',
		'2024-06-25',
		'2024-07-15',
		'2024-07-12',
		'2024-07-18',
		'2024-06-28',
		'2024-07-09',
		'2024-07-22',
		'2024-07-20',
		'2024-07-19',
		'2024-06-24',
		'2024-07-10',
		'2024-07-21',
		'2024-07-17',
		'2024-07-11',
	]
	next_id = 101
	for pdate in pdates:
		cust = custs[next_id]
		val = f"( {next_id}, '{cust["fname"]}', '{cust["lname"]}', '{cust["email"]}', '{pdate}' )"
		values.append(val)
		next_id += 1
	values_str = ',\n'.join(values) + ';'
	sql += values_str
	print(sql)


def seed_newsletter_subscriptions(custs):
	sql = "INSERT INTO newsletter_subscriptions " \
		"(customer_id, first_name, last_name, email, subscription_date) VALUES \n"
	values = []

	records = [
		(101, '2024-07-01'),
		(109, '2024-07-05'),
		(116, '2024-06-29'),
		(112, '2024-07-03'),
		(117, '2024-07-15'),
		(113, '2024-06-30'),
		(118, '2024-07-06'),
		(105, '2024-07-18'),
		(106, '2024-07-20'),
		(115, '2024-07-22'),
		(119, '2024-07-08'),
		(107, '2024-07-10'),
		(108, '2024-07-13'),
		(114, '2024-07-14'),
		(104, '2024-07-11'),
	]
	for cid, sdate in records:
		cust = custs[cid]
		val = f"( {cid}, '{cust["fname"]}', '{cust["lname"]}', '{cust["email"]}', '{sdate}' )"
		values.append(val)
	values_str = ',\n'.join(values) + ';'
	sql += values_str
	print(sql)


def seed_returns(custs):
	sql = "INSERT INTO `returns` " \
		"(customer_id, first_name, last_name, email, return_date) VALUES \n"
	values = []

	records = [
		(103, '2024-07-17'),
		(102, '2024-07-14'),
		(104, '2024-07-19'),
		(110, '2024-07-08'),
		(105, '2024-07-21'),
		(107, '2024-07-10'),
		(111, '2024-07-16'),
		(116, '2024-07-02'),
		(117, '2024-07-18'),
		(112, '2024-07-07'),
		(108, '2024-07-09'),
		(114, '2024-07-11'),
		(109, '2024-07-12'),
		(113, '2024-07-20'),
		(101, '2024-07-22'),
	]
	for cid, rdate in records:
		cust = custs[cid]
		val = f"( {cid}, '{cust["fname"]}', '{cust["lname"]}', '{cust["email"]}', '{rdate}' )"
		values.append(val)
	values_str = ',\n'.join(values) + ';'
	sql += values_str
	print(sql)


def customers_master():

	def build_cust(fname, lname):
		return {
			'fname': fname,
			'lname': lname,
			'email': f"{fname.lower()}.{lname.lower()}@example.com",
		}

	custs = {
		101: ('Aarav', 'Sharma'),
		102: ('Vihaan', 'Singh'),
		103: ('Aditi', 'Mehta'),
		104: ('Rohan', 'Kumar'),
		105: ('Isha', 'Patel'),
		106: ('Kavya', 'Verma'),
		107: ('Arjun', 'Reddy'),
		108: ('Ananya', 'Nair'),
		109: ('Saanvi', 'Gupta'),
		110: ('Kabir', 'Agarwal'),
		111: ('Neha', 'Saxena'),
		112: ('Tanishq', 'Rana'),
		113: ('Mira', 'Bhatt'),
		114: ('Dev', 'Kapoor'),
		115: ('Riya', 'Joshi'),
		116: ('Lakshay', 'Malhotra'),
		117: ('Sneha', 'Chawla'),
		118: ('Rahul', 'Pillai'),
		119: ('Nikhil', 'Chandra'),
	}
	full_custs = { cid: build_cust(*cval) for cid, cval in custs.items() }
	return full_custs


if __name__ == '__main__':
	main()
