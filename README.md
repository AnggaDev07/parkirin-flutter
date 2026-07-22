# 🅿️ Parkirin - Batam City Cashless Parking Payment System

**Parkirin** is a smart mobile application (*on-street parking*) specifically designed to modernize the parking system in Batam City. This application digitalizes the vehicle recording process and facilitates *cashless* payment transactions, creating a more transparent, fast, and efficient parking experience for both drivers and parking attendants.

---

## 🛠️ Technologies & Architecture (Tech Stack)

This application is built with a focus on high performance and maintainable code using **Flutter Clean Architecture** (divided into *Entities, Use Cases, Repository/Presenter, and Data Source/UI*).

*   **Programming Language:** Dart
*   **Framework:** Flutter
*   **Database (BaaS):** Firebase (Authentication & Firestore)
*   **Payment Gateway:** Midtrans (Integrated for *cashless* payment methods)
*   **UI/UX Design:** Figma

---

## ✨ Key Features

This system separates the workflow into two main roles:

### 🚗 Driver Side
*   **Easy Authentication:** Register and log in using a Phone Number (OTP verification) or direct integration with a Google Account.
*   **Vehicle Management (CRUD):** Register, update, or delete license plates and vehicle types within the profile.
*   **Flexible Payment:** Pay parking bills *cashless* through various payment methods (*Payment Gateway*), or use the Point redemption system (Redeem 2000 Points for 1x free parking).
*   **Parking History:** Monitor the complete trail of parking activities and previously made payment statuses.

### 👷 Parking Attendant Side
*   **Secure Login:** Uses the Parking Attendant Identification Number (NIJP) and a specific password registered in the system.
*   **Fast Ticket Creation:** Issue new parking tickets by inputting the vehicle type, license plate, and payment method (*Bill Driver* for app users, or *Record Parking* for non-app users).
*   **Editing Flexibility:** Feature to update or correct parking ticket details (valid before the 10-minute time limit since the ticket was created).
*   **Daily Statistics:** A dedicated dashboard displaying the total number of tickets, pending tickets, paid tickets, and estimated revenue in *real-time*.

---