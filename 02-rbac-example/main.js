const morgan = require('morgan')
const hbs = require('express-handlebars')
const express = require('express')
const cookieParser = require('cookie-parser')
const fetch = require('node-fetch');
const jwt = require('jsonwebtoken')

const SECRET = process.env.SECRET || 'changeit'
const PORT = parseInt(process.env.PORT) || 3000
const OPA_ADDRESS = process.env.OPA_ADDRESS || 'localhost:8181'

const mkQuery = (url) =>
	(input) => fetch(url, { 
			method: 'POST',
			body: JSON.stringify(input),
			headers: { 'Content-Type': 'application/json' }
		}).then(resp => resp.json())

const allow = mkQuery(`http://${OPA_ADDRESS}/v1/data/authz/allow`)
const deny = mkQuery(`http://${OPA_ADDRESS}/v1/data/authz/deny`)

const employees = [
	{ name: "fred", grade: "regular", expenseLimit: 300 },
	{ name: "barney", grade: "regular" , expenseLimit: 400 },
	{ name: "wilma", grade: "team-lead", reports: [ "fred", "barney" ], expenseLimit: 800 }
]

const app = express()

app.engine('hbs', hbs({ defaultLayout: false }))
app.set('view engine', 'hbs')

app.use(morgan('common'))

app.use(cookieParser(), express.urlencoded({ extended: true }))

app.post('/login', (req, resp) => {
		const empDetails = employees.find(v => v.name == req.body.username)
		if (!empDetails) {
			return resp.status(401).render('error', { message: `Cannot find user ${req.body.username}` })
		}

		const token = jwt.sign({
			iss: 'acme',
			sub: empDetails.name,
			aud: 'myapp',
			iat: (new Date()).getTime() / 1000,
			data: {
				name: empDetails.name,
				grade: empDetails.grade
			},
		}, SECRET)

		resp.cookie('token', token, { httpOnly: true })
		resp.status(200).type('text/html')
			.sendFile(`${__dirname}/static/requisition.html`)
	}
)

app.post('/po', (req, resp) => {
	const token = req.cookies.token
	if (!token)
		return resp.redirect("/")

	try {
		const decoded = jwt.verify(token, SECRET)
		const empDetails = employees.find(v => v.name == decoded.data.name)
		if (!empDetails)
			return resp.status(401).render('error', { message: `Cannot find user ${req.body.username}` })

		const input = {
			name: decoded.data.name,
			grade: decoded.data.grade,
			unitPrice: parseInt(req.body.unitPrice) || 100000,
			quantity: parseInt(req.body.quantity) || 100000,
			expenseLimit: empDetails.expenseLimit
		}
		console.info('\n*** input: ', input)

		deny({ input })
			.then(result => {
				console.info('\n*** result: ', result)

				if (Object.values(result.result).length <= 0)
					return resp.status(200)
						.render('approved', { 
							name: input.name,
							amount: input.unitPrice * input.quantity
						})

				resp.status(400)
					.render("denied", { 
						name: input.name,
						amount: input.unitPrice * input.quantity,
						reasons: Object.values(result.result)
					})
			})
	} catch(err) {
		return resp.status(401).render('error', { message: err })
	}
})

app.use(express.static(`${__dirname}/static`))

app.listen(PORT, () => {
	console.info(`Application started on port ${PORT} at ${new Date()}`)
})
