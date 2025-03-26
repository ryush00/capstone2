import { Controller } from "@hotwired/stimulus"

// POST 방식으로 게시글 원본 페이지를 여는 Stimulus 컨트롤러
export default class extends Controller {
  static values = {
    gid: String,
    bid: String,
    cid: String,
    lpage: { type: String, default: "1" }
  }

  // form 요소를 생성하고 POST 요청을 보냄
  view(event) {
    event.preventDefault()
    
    // 임시 form 생성
    const form = document.createElement("form")
    form.method = "post"
    form.action = "https://cyber.wku.ac.kr/Cyber/ComBoard_V005/Content/view.jsp"
    form.target = "_blank"
    
    // 폼 필드 추가
    this.addField(form, "gid", this.gidValue)
    this.addField(form, "bid", this.bidValue)
    this.addField(form, "cid", this.cidValue)
    this.addField(form, "lpage", this.lpageValue)
    
    // 폼을 문서에 추가하고 제출
    document.body.appendChild(form)
    form.submit()
    
    // 폼 제거
    document.body.removeChild(form)
  }
  
  // 폼에 필드 추가하는 헬퍼 메소드
  addField(form, name, value) {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = name
    input.value = value
    form.appendChild(input)
  }
}