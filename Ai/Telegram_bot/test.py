import logging
import firebase_admin
from firebase_admin import credentials, firestore
from telegram import Update, ReplyKeyboardMarkup, KeyboardButton
from telegram.ext import (
    ApplicationBuilder,
    CommandHandler,
    MessageHandler,
    ContextTypes,
    filters,
    ConversationHandler,
)
import os
from dotenv import load_dotenv

load_dotenv()

# ----------------- Logging -----------------
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)

# ----------------- Firebase -----------------
cred = credentials.Certificate("hacktues12-firebase-adminsdk-fbsvc-7ce9f543c1.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

BOT_TOKEN = os.getenv("BOT_KEY_TOKEN")

# ----------------- Conversation states -----------------
PHONE, CHOICE, PRODUCT_SELECT = range(3)

# ----------------- /start -----------------
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    keyboard = ReplyKeyboardMarkup(
        [[KeyboardButton("Share phone", request_contact=True)]],
        resize_keyboard=True,
        one_time_keyboard=True
    )
    await update.message.reply_text(
        "Connected! Please share your phone number to start:",
        reply_markup=keyboard
    )
    return PHONE

# ----------------- Handle phone -----------------
async def handle_contact(update: Update, context: ContextTypes.DEFAULT_TYPE):
    contact = update.message.contact
    phone = contact.phone_number

    # Normalize
    if phone.startswith("359"):
        phone_clean = "0" + phone[3:]
    else:
        phone_clean = phone

    context.user_data["phone"] = phone_clean

    # Ask choice
    keyboard = ReplyKeyboardMarkup(
        [["User Details", "Product Details"]],
        resize_keyboard=True
    )
    await update.message.reply_text(
        "Phone received! What would you like to see?",
        reply_markup=keyboard
    )
    return CHOICE

# ----------------- Handle choice -----------------
async def handle_choice(update: Update, context: ContextTypes.DEFAULT_TYPE):
    choice = update.message.text
    context.user_data["choice"] = choice
    phone = context.user_data.get("phone")

    # Get user document by phone
    users_ref = db.collection("users")
    query = users_ref.where("phoneNumber", "==", phone).limit(1).stream()
    user_doc = None
    for doc in query:
        user_doc = doc
    if not user_doc:
        await update.message.reply_text("No user found.")
        return ConversationHandler.END

    context.user_data["user_doc_id"] = user_doc.id
    user_data = user_doc.to_dict()
    context.user_data["user_data"] = user_data

    if choice == "User Details":
        # Print all top-level user fields except system fields
        exclude_fields = ["phoneNumber", "createdAt", "updatedAt"]
        user_details = {k: v for k, v in user_data.items() if k not in exclude_fields}
        if not user_details:
            await update.message.reply_text("No user details found.")
        else:
            message = "User Details:\n" + "\n".join([f"{k}: {v}" for k, v in user_details.items()])
            await update.message.reply_text(message)

        # Go back to main menu
        keyboard = ReplyKeyboardMarkup(
            [["User Details", "Product Details"]],
            resize_keyboard=True
        )
        await update.message.reply_text("What would you like to see next?", reply_markup=keyboard)
        return CHOICE

    elif choice == "Product Details":
        # Fetch products from subcollection
        products_ref = db.collection("users").document(user_doc.id).collection("products")
        products_docs = list(products_ref.stream())
        if not products_docs:
            await update.message.reply_text("You have no products.")
            return ConversationHandler.END

        # Store products in user_data
        products = {doc.id: doc.to_dict() for doc in products_docs}
        context.user_data["products"] = products

        # Show list of product names as buttons
        product_names = [p.get("productName", f"Product {i+1}") for i, p in enumerate(products.values())]
        keyboard = ReplyKeyboardMarkup([[name] for name in product_names], resize_keyboard=True)
        await update.message.reply_text("Select a product:", reply_markup=keyboard)
        return PRODUCT_SELECT
    else:
        await update.message.reply_text("Please choose a valid option.")
        return CHOICE

# ----------------- Handle product selection -----------------
async def handle_product_select(update: Update, context: ContextTypes.DEFAULT_TYPE):
    selected_name = update.message.text
    # Find product by name
    products = context.user_data.get("products", {})
    product_data = None
    for p in products.values():
        if p.get("productName") == selected_name:
            product_data = p
            break

    if not product_data:
        await update.message.reply_text("No data for this product.")
    else:
        message = f"{selected_name} Details:\n" + "\n".join([f"{k}: {v}" for k, v in product_data.items()])
        await update.message.reply_text(message)

    # Go back to main menu
    keyboard = ReplyKeyboardMarkup(
        [["User Details", "Product Details"]],
        resize_keyboard=True
    )
    await update.message.reply_text("What would you like to see next?", reply_markup=keyboard)
    return CHOICE

# ----------------- Cancel -----------------
async def cancel(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("Chat ended.")
    return ConversationHandler.END

# ----------------- Main -----------------
def main():
    app = ApplicationBuilder().token(BOT_TOKEN).build()

    conv_handler = ConversationHandler(
        entry_points=[CommandHandler("start", start)],
        states={
            PHONE: [MessageHandler(filters.CONTACT, handle_contact)],
            CHOICE: [MessageHandler(filters.TEXT & ~filters.COMMAND, handle_choice)],
            PRODUCT_SELECT: [MessageHandler(filters.TEXT & ~filters.COMMAND, handle_product_select)],
        },
        fallbacks=[CommandHandler("cancel", cancel)],
    )

    app.add_handler(conv_handler)

    print("🚀 Bot is running...")
    app.run_polling()

if __name__ == "__main__":
    main()