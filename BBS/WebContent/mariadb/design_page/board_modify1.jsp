<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.NamingException" %>

<%@ page import="javax.sql.DataSource" %>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%
	request.setCharacterEncoding("utf-8");
	
	String seq = request.getParameter("seq");
	String cpage = request.getParameter("cpage");
	
	String subject = "";
	String writer = "";
	String content = "";
	String emot = "";
	String[] mail = null;
	String filename = "";
	long filesize = 0;
	
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	try {
		Context initCtx = new InitialContext();
		Context envCtx = (Context)initCtx.lookup("java:comp/env");
		DataSource dataSource = (DataSource)envCtx.lookup("jdbc/mariadb1");
		
		conn = dataSource.getConnection();
				
		String sql = "select subject, writer, mail, content, emot, filename, filesize from board1 where seq="+ seq;
		pstmt = conn.prepareStatement(sql);
		
		rs = pstmt.executeQuery();
		
		if (rs.next()) {
			subject = rs.getString("subject");
			writer = rs.getString("writer");
			if (rs.getString("mail").equals("")) {
				mail = new String[] {"", ""};
			} else {
				mail = rs.getString("mail").split("@");
			}
			content = rs.getString("content").replaceAll("\n", "<br>");
			emot = rs.getString("emot");
			filename = rs.getString("filename") == null ? "파일없음" : rs.getString("filename");
			filesize = rs.getLong("filesize");
		}
	} catch (NamingException e) {
		System.out.println("[에러] : " + e.getMessage());
	} catch (SQLException e) {
		System.out.println("[에러] : " + e.getMessage());
	} finally {
		if (rs != null) rs.close();
		if (pstmt != null) pstmt.close();
		if (conn != null) conn.close();
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>JSP 게시판</title>
<link rel="stylesheet" type="text/css" href="../../css/board_write.css">
<script type="text/javascript">
window.onload = function() {
	document.getElementById('mbtn').onclick = function() {
		if (document.mfrm.subject.value.trim() == '') {
			alert('제목을 입력하셔야 합니다.');
			return false;
		}
		if (document.mfrm.password.value.trim() == '') {
			alert('비밀번호를 입력하셔야 합니다.');
			return false;
		}
		document.mfrm.submit();
	};
};
</script>
</head>

<body>
<!-- 상단 디자인 -->
<div class="con_title">
	<h3>게시판</h3>
	<p>HOME &gt; 게시판 &gt; <strong>게시판</strong></p>
</div>
<div class="con_txt">
	<form action="./board_modify1_ok.jsp" method="post" name="mfrm" enctype="multipart/form-data">
		<input type="hidden" name="seq" value="<%=seq %>" />
		<input type="hidden" name="cpage" value="<%=cpage %>" />
		<div class="contents_sub">	
			<div class="board_write">
				<table>
					<tr>
						<th class="top">글쓴이</th>
						<td class="top" colspan="3"><input type="text" name="writer" value="<%=writer %>" class="board_view_input_mail" maxlength="5" readonly /></td>
					</tr>
					<tr>
						<th>제목</th>
						<td colspan="3"><input type="text" name="subject" value="<%=subject %>" class="board_view_input" /></td>
					</tr>
					<tr>
						<th>비밀번호</th>
						<td colspan="3"><input type="password" name="password" value="" class="board_view_input_mail" /></td>
					</tr>
					<tr>
						<th>내용</th>
						<td colspan="3"><textarea name="content" class="board_editor_area"><%=content %></textarea></td>
					</tr>
					<tr>
						<th>이메일</th>
						<td colspan="3"><input type="text" name="mail1" value="<%=mail[0] %>" class="board_view_input_mail"/> @ <input type="text" name="mail2" value="<%=mail[1] %>" class="board_view_input_mail" /></td>
					</tr>
					<tr>
						<th>첨부파일</th>
						<td colspan="3">
							기존 파일명 : <%=filename %>(<%=filesize %>KB)<br><br>
							<input type="file" name="upload" value="" class="board_view_input" />
						</td>
					</tr>
					<tr>
						<th>이모티콘</th>
						<td colspan="3" align="center">			
						<table>
						<% String strHtml = ""; %>
<%
							strHtml += "<tr>";
							for (int i = 1; i < 46; i++) {
						    	strHtml += "<td>";
						   		strHtml += "<img src='../../images/emoticon/emot";
						    	if (i < 10) {
						       		strHtml += "0";
						    	}
							    strHtml += i;
							    strHtml += ".png' width='25' /><br>";
							    strHtml += "<input type='radio' name='emot' value='emot";
							    if (i < 10) {
							       strHtml += "0";
							    }
							    strHtml += i;
							    strHtml += "' class='input_radio' ";
							    if (Integer.parseInt(rs.getString("emot")) == i) {
							       strHtml += "checked='checked'";
							    }
							    strHtml += "/>";
							    strHtml += "</td>";
							    if (i % 15 == 0 && i < 45) {
							       strHtml += "</tr>";
							       strHtml += "<tr>";
							    }
							 }
							 strHtml += "</tr>";
							 
%>
						<%=strHtml %>
						</table>
						</td>
					</tr>
				</table>
			</div>
			<div class="btn_area">
				<div class="align_left">
					<input type="button" value="목록" class="btn_list btn_txt02" style="cursor: pointer;" onclick="location.href='board_list1.jsp?cpage=<%=cpage %>'" />
					<input type="button" value="보기" class="btn_list btn_txt02" style="cursor: pointer;" onclick="location.href='board_view1.jsp?cpage=<%=cpage %>&seq=<%=seq %>'" />
				</div>
				<div class="align_right">
					<input type="button" id="mbtn" value="수정" class="btn_write btn_txt01" style="cursor: pointer;"/>
				</div>
			</div>
		</div>
	</form>
</div>

</body>
</html>
