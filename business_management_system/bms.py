import datetime

class BusinessManagementSystem:
    def __init__(self):
        self.inventory = {}
        self.sales_history = []
        self.customers = {}

    def add_product(self, product_name, quantity, price):
        if product_name in self.inventory:
            self.inventory[product_name]['quantity'] += quantity
        else:
            self.inventory[product_name] = {'quantity': quantity, 'price': price}
        print(f"{quantity} {product_name} added to inventory.")

    def remove_product(self, product_name, quantity):
        if product_name in self.inventory:
            if self.inventory[product_name]['quantity'] >= quantity:
                self.inventory[product_name]['quantity'] -= quantity
                print(f"{quantity} {product_name} removed from inventory.")
            else:
                print(f"Insufficient {product_name} in inventory.")
        else:
            print(f"{product_name} not found in inventory.")

    def view_inventory(self):
        if self.inventory:
            print("Inventory:")
            for product_name, details in self.inventory.items():
                print(f"  {product_name}: {details['quantity']} units, ${details['price']:.2f} per unit")
        else:
            print("Inventory is empty.")

    def add_customer(self, customer_name, phone_number):
        if customer_name in self.customers:
            print(f"Customer '{customer_name}' already exists.")
        else:
            self.customers[customer_name] = {'phone': phone_number}
            print(f"Customer '{customer_name}' added successfully.")

    def remove_customer(self, customer_name):
        if customer_name in self.customers:
            del self.customers[customer_name]
            print(f"Customer '{customer_name}' removed successfully.")
        else:
            print(f"Customer '{customer_name}' not found.")

    def view_customers(self):
        if self.customers:
            print("Customers:")
            for customer_name, details in self.customers.items():
                print(f"  {customer_name}: {details['phone']}")
        else:
            print("No customers registered.")

    def make_sale(self, customer_name, products):
        sale_items = []
        total_amount = 0
        for product_name, quantity in products.items():
            if product_name in self.inventory:
                if self.inventory[product_name]['quantity'] >= quantity:
                    self.inventory[product_name]['quantity'] -= quantity
                    sale_items.append({'product': product_name, 'quantity': quantity, 'price': self.inventory[product_name]['price']})
                    total_amount += quantity * self.inventory[product_name]['price']
                else:
                    print(f"Insufficient {product_name} in inventory.")
            else:
                print(f"{product_name} not found in inventory.")

        if sale_items:
            sale_date = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            sale_record = {
                'date': sale_date,
                'customer': customer_name,
                'items': sale_items,
                'total_amount': total_amount
            }
            self.sales_history.append(sale_record)
            print("Sale completed successfully!")
            print(f"Total amount: ${total_amount:.2f}")
            print(f"Items sold: {sale_items}")
        else:
            print("Sale failed. No items sold.")

    def view_sales_history(self):
        if self.sales_history:
            print("Sales History:")
            for i, sale in enumerate(self.sales_history):
                print(f"  Sale {i+1}:")
                print(f"    Date: {sale['date']}")
                print(f"    Customer: {sale['customer']}")
                print(f"    Items:")
                for item in sale['items']:
                    print(f"      {item['product']}: {item['quantity']} units, ${item['price']:.2f} per unit")
                print(f"    Total amount: ${sale['total_amount']:.2f}")
        else:
            print("No sales recorded yet.")

if __name__ == "__main__":
    bms = BusinessManagementSystem()

    while True:
        print("\nBusiness Management System")
        print("1. Add Product")
        print("2. Remove Product")
        print("3. View Inventory")
        print("4. Add Customer")
        print("5. Remove Customer")
        print("6. View Customers")
        print("7. Make Sale")
        print("8. View Sales History")
        print("9. Exit")

        choice = input("Enter your choice: ")

        if choice == '1':
            product_name = input("Enter product name: ")
            quantity = int(input("Enter quantity: "))
            price = float(input("Enter price: "))
            bms.add_product(product_name, quantity, price)
        elif choice == '2':
            product_name = input("Enter product name: ")
            quantity = int(input("Enter quantity: "))
            bms.remove_product(product_name, quantity)
        elif choice == '3':
            bms.view_inventory()
        elif choice == '4':
            customer_name = input("Enter customer name: ")
            phone_number = input("Enter phone number: ")
            bms.add_customer(customer_name, phone_number)
        elif choice == '5':
            customer_name = input("Enter customer name: ")
            bms.remove_customer(customer_name)
        elif choice == '6':
            bms.view_customers()
        elif choice == '7':
            customer_name = input("Enter customer name: ")
            products = {}
            while True:
                product_name = input("Enter product name (or 'done' to finish): ")
                if product_name.lower() == 'done':
                    break
                quantity = int(input("Enter quantity: "))
                products[product_name] = quantity
            bms.make_sale(customer_name, products)
        elif choice == '8':
            bms.view_sales_history()
        elif choice == '9':
            break
        else:
            print("Invalid choice.")
