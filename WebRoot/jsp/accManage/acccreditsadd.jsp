<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<script type="text/javascript">
	var $cardinfo;
	$(function(){
		addNumberValidById("maxNum");
		if(dealNull("${defaultErrorMsg}") != ""){
			$.messager.alert("系统消息","${defaultErrorMsg}","error");
		}
		$("#minAmt").validatebox({required:true,validType:"email",invalidMessage:"请输入勾选账户的小额免密码支付的最大金额<br/><span style=\"color:red\">提示：勾选账户的消费金额小于该设置金额时可免输入密码进行支付。</span>",missingMessage:"请输入勾选账户的小额免密码支付的最大金额<br/><span style=\"color:red;\">提示：勾选账户的消费金额小于该设置金额时可免输入密码进行支付。</span>"});
		$("#amt").validatebox({required:true,validType:"email",invalidMessage:"请输入勾选账户的单笔最大可消费金额<br/><span style=\"color:red\">提示：该账户单笔消费金额大于该设置金额时，将拒绝此次交易。</span>",missingMessage:"请输入勾选账户的单笔最大可消费金额<br/><span style=\"color:red\">提示：该账户单笔消费金额大于该设置金额时，将拒绝此次交易。</span>"});
		$("#maxAmt").validatebox({required:true,validType:"email",invalidMessage:"请输入勾选账户单日累计最大可消费金额<br/><span style=\"color:red\">提示：勾选账户单日累计消费金额大于该本日累计消费限额时，则拒绝交易。</span>",missingMessage:"请输入勾选账户单日累计最大可消费金额<br/><span style=\"color:red;\">提示：勾选账户单日累计消费金额大于该本日累计消费限额时，则拒绝交易。</span>"});
		$("#minAmt").validatebox("validate");
		$("#amt").validatebox("validate");
		$("#maxAmt").validatebox("validate");
		createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
		$cardinfo = $("#cardinfo");
		$cardinfo.datagrid({
			url:"accountManager/accountManagerAction!toAccLimitAccMsgQuery.action",
			fit:true,
			pagination:false,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			checkOnSelect:true,
			scrollbarSize:0,
			fitColumns:true,
			columns:[[
				{field:'V_V',checkbox:true},
	        	{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:'CERT_TYPE',title:'证件类型',sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width() * 0.12)},
	        	{field:'CARD_TYPE',title:'卡类型',sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width() * 0.15)},
	        	{field:'CARD_STATE',title:'卡状态',sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:'BUS_TYPE',title:'公交类型',sortable:true}
	        ]],
		 	toolbar:'#tb1',
            onLoadSuccess:function(data){
	           	 if(data.status != 0){
	           		 $.messager.alert('系统消息',data.errMsg,'error');
	           	 }
	           	 if(data.rows.length > 0 ){
		           	 $("#cardinfo").datagrid('selectRow',0);
	           	 }
            },
            onSelect:function(index,data){
           	    if(data == null)return;
	            $("#accinfo").get(0).src = "jsp/cardService/inneraccinfo.jsp?accKind=02&isChecked=true&cardNo=" + data.CARD_NO;
	            if($("#accinfodiv").css("display") != "block"){
		            $("#accinfodiv").show();
	            }
          	}
		 });
	});
	//读卡,对卡号进行复制，并设置读卡标志，并设置是好卡
	function readCard(){
		cardmsg = getcardinfo();
		if(dealNull(cardmsg["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
			return;
		}
		$("#cardNo1").val(cardmsg["card_No"]);
		$("#cardAmt").val((parseFloat(isNaN(cardmsg['wallet_Amt']) ? 0:cardmsg['wallet_Amt'])/100).toFixed(2));
		querycardinfo();
	}
	function querycardinfo(){
		if($("#certNo1").val().replace(/\s/g,'') == '' && $("#cardNo1").val().replace(/\s/g,'') == ''){
			$.messager.alert('系统消息','请输入查询证件号码或是卡号以获取账户信息！','error');
			return;
		}
		$("input[type=checkbox]").each(function(){
			this.checked = false;
		});
		$cardinfo.datagrid('load',{
			queryType:'0',//查询类型
			"bp.certNo":$('#certNo1').val(),
			"card.cardNo":$('#cardNo1').val()
		});
	}
	function getSubAccinfo(){
		if($("#accinfodiv").css("display") == "block"){
			var curdata = accinfo.window.getSelectedData();
			if(curdata){
				return curdata;
			}else{
				$.messager.alert("系统消息","请勾选账户信息！","error");
			}
		}else{
			$.messager.alert("系统消息","请先进行查询已获取账户信息！","error");
		}
	}
	function saveOrUpdateAccLimit(){
		var cdata = getSubAccinfo();
		if(!cdata){
			return;
		}
		if($("#amt").val() == ""){
			$.messager.alert("系统消息","请输入勾选账户的单笔消费最大限额！","error",function(){
				$("#amt").focus();
			});
			return;
		}
		if($("#maxAmt").val() != ""){
			if(parseFloat($("#amt").val()) > parseFloat($("#maxAmt").val())){
				$.messager.confirm("系统消息","您确定要继续吗？<span style=\"color:red\">账户单日累计消费限额小于单笔消费最大限额，可能导致账户无法消费！</span>",function(r){
					if(r){
						saveSec(cdata);
					}
				});
				return;
			}
		}
		saveSec(cdata);
		/* $.messager.confirm("系统消息","您确定要设置勾选账户的限额信息吗？",function(r){
			if(r){
				$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				$.post("/accountManager/accountManagerAction!saveOrUpdateAccLimit.action",
						$("#form").serialize() + "&limit.cardNo=" + cdata.CARD_NO + "&limit.accKind=" + cdata.ACC_KIND + "&queryType=0",
						function(data,status){
							$.messager.progress('close');
							$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function() {
								 if(data.status == "0"){
									 $dg.datagrid("reload");
									 $.modalDialog.handler.dialog('destroy');
									 $.modalDialog.handler = undefined;
								 }
							});
				},"json");
			}
		}); */
	}
	function saveSec(tempdata){
		$.messager.confirm("系统消息","您确定要设置勾选账户的限额信息吗？",function(r){
			if(r){
				$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				$.post("accountManager/accountManagerAction!saveOrUpdateAccLimit.action",
						$("#form").serialize() + "&limit.cardNo=" + tempdata.CARD_NO + "&limit.accKind=" + tempdata.ACC_KIND + "&queryType=0",
						function(data,status){
							$.messager.progress('close');
							$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function() {
								 if(data.status == "0"){
									 $dg.datagrid("reload");
									 $.modalDialog.handler.dialog('destroy');
									 $.modalDialog.handler = undefined;
								 }
							});
				},"json");
			}
		});
	}
	function readIdCard(){
		var o = getcertinfo();
		if(dealNull(o["name"]).length == 0){
			return;
		}
		$("#certNo1").val(o["cert_No"]);
		querycardinfo();
	}
	
	function validRmb(obj){
		var v = obj.value;
		var exp = /^\d+(\.?\d{0,2})?$/g;
		if(!exp.test(v)){
			obj.value = v.substring(0,v.length - 1);
		}else{
			var zeroexp = /^0{2,}$/g;
			if(zeroexp.test(v)){
				obj.value = 0;
			}
		}
	}
	
</script>
<div class="easyui-layout" data-options="fit:true,border:false" style="background-color:rgb(245,245,245);margin-top:-4px;">
	<div data-options="region:'center',border:false" style="margin:0px;width:auto">
	  	<div id="tb1">
			<table>
				<tr>
					<tr>
						<td style="padding-left:2px">证件号码：</td>
						<td style="padding-left:2px"><input name="bp.certNo" class="textinput" id="certNo1" type="text" /></td>
						<td style="padding-left:2px">卡号：</td>
						<td style="padding-left:2px"><input name="card.cardNo" class="textinput" id="cardNo1" type="text" /></td>
						<td style="padding-left:2px">卡余额：</td>
						<td style="padding-left:2px"><input id="cardAmt" type="text" class="textinput" name="cardAmt" style="width:174px;" readonly="readonly"/></td>
						<td style="padding-left:2px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="querycardinfo()">查询</a>
						</td>
				</tr>
			</table>
		</div>
  		<table id="cardinfo" title="个人卡片基本信息"></table>
	</div>
	<div data-options="region:'south',split:false,border:true" style="height:300px; width:auto;text-align:center;border-left:none;border-bottom:none;overflow:hidden;">
		<div style="width:100%;display:none;" id="accinfodiv">
  			<h3 class="subtitle">账户信息</h3>
  			<iframe name="accinfo" id="accinfo"  width="100%" style="border:none;height:52px;padding:0px;margin:0px;"></iframe>
		</div>
		<div style="width:100%;height:100%" class="datagrid-toolbar">
			<form id="form" method="post">
				 <h3 class="subtitle">代理人信息</h3>
				 <table class="tablegrid" style="width:100%;">
				 	<tr>
				 		<th class="tableleft">小额免密码支付：</th>
						<td class="tableright"><input name="minAmt"  class="textinput" id="minAmt" type="text" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/></td>
						<th class="tableleft">单日消费最大笔数：</th>
						<td class="tableright"><input name="maxNum" id="maxNum" type="text" class="textinput" ></td>
						<th class="tableleft">单笔消费最大额度：</th>
						<td class="tableright"><input name="amt"  class="textinput" id="amt" type="text" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/></td>
						<th class="tableleft">单日消费最大额度：</th>
						<td class="tableright"><input name="maxAmt"  class="textinput" id="maxAmt" type="text" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/></td>
					</tr>
					<tr>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright"><input name="rec.agtCertType"  class="textinput" id="agtCertType" type="text"/></td>
						<th class="tableleft">证件号码：</th>
						<td class="tableright"><input name="rec.agtCertNo"  class="textinput easyui-validatebox" id="rec.agtCertNo" type="text" maxlength="18" validtype="idcard"/></td>
						<th class="tableleft">姓名：</th>
						<td class="tableright"><input name="rec.agtName" id="rec.agtName" type="text" class="textinput easyui-validatebox"  maxlength="30" /></td>
					 	<th class="tableleft">联系电话：</th>
						<td class="tableright"><input name="rec.agtTelNo" id="rec.agtTelNo" type="text" class="textinput easyui-validatebox" maxlength="11" validtype="mobile"></td>
					</tr>
			  	</table>
		 	 </form>	
	 	</div>
	</div>
</div>