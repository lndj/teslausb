import axios from 'axios'
import qs from 'qs'
import Cookies from "js-cookie"

// create an axios instance
const service = axios.create({
  // baseURL: 'http://localhost:8090',
  withCredentials: true, // send cookies when cross-domain requests
  // timeout: 40000, // request timeout
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Access-Control-Allow-Origin': '*'
  }
})

// request interceptor
service.interceptors.request.use(
  config => {
    if (config.method === 'post') {
      config.data = qs.stringify(config.data)
    }
    if (config.method === 'get') {
      config.paramsSerializer = function (params) {
        return qs.stringify(params, { arrayFormat: 'repeat' })
      }
    }
    return config
  },
  error => {
    // do something with request error
    console.log(error) // for debug
    return Promise.reject(error)
  }
)

// response interceptor
service.interceptors.response.use(
  /**
   * If you want to get http information such as headers or status
   * Please return  response => response
  */

  /**
   * Determine the request status by custom code
   * Here is just an example
   * You can also judge the status by HTTP Status Code
   */
  response => {
    const res = response.data
    console.log(res)
    // if the custom code is not 0, it is judged as an error.
    // if (res.code !== 0) {
    //   return Promise.reject(new Error(res.msg || 'Error'))
    // }
    return res
  },
  error => {
    if (error.request.status === 401) {
      Cookies.remove("X-Token");
    }
    console.error(error) // for debug
    return Promise.reject(error)
  }
)

export default service
