<%@page import="com.erp.util.DealCode"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
    var $gridview;
    var selectIdView = "${param.cardNo}";
    var tempQueryType = "${param.tempQueryType}";
    $(function(){
        $gridview = createDataGrid({
            id:"dgview",
            url:"cardService/cardServiceAction!queryCardAppOpenOrCloseHjl.action?cardNo=" + selectIdView + "&tempQueryType=" + tempQueryType,
            border:false,
            fit:true,
            fitColumns:true,
            singleSelect:true,
            pageSize:20,
            queryParams:{queryType:"0"},
            scrollbarSize:0,
            columns:[[
                {field:"SELECTID",checkbox:true},
                {field:"CUSTOMER_NAME",title:"姓名",sortable:true,width : parseInt($(this).width() * 0.06)},
                {field:"CERTTYPE",title:"证件类型",sortable:true,width:parseInt($(this).width() * 0.06)},
                {field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.15)},
                {field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"DEAL_CODE_NAME",title:"交易类型",sortable:true,width:parseInt($(this).width()*0.08)},
                {field:"DEALSTATE",title:"交易状态",sortable:true,width:parseInt($(this).width()*0.08)},
                {field:"BIZTIME",title:"交易时间",sortable:true,width:parseInt($(this).width()*0.12)},
                {field:"BRCHNAME",title:"受理网点",sortable:true,width:parseInt($(this).width()*0.12)},
                {field:"USERNAME",title:"受理柜员",sortable:true,width:parseInt($(this).width()*0.12)}
            ]],
            toolbar:[
                {
                    iconCls: 'icon-save',
                    text:"<span style='font-weight: bold'>确认</span>",
                    handler: function(){
                        var curRow = $gridview.datagrid("getSelected");
                        if(!curRow || dealNull(curRow["DEAL_NO"]) == ""){
                            jAlert("请勾选一条记录信息进行确认！","warning");
                            return;
                        }else{
                            $.messager.confirm("系统消息","您确认要取消勾选的应用开通灰记录吗？",function(r) {
                                if(r){
                                    $.messager.progress({text:"正在进行确认，请稍后...."});
                                    var ywlx = "1";
                                    if(curRow["DEAL_CODE"] == "<%=DealCode.ZXC_APP_OPEN%>"){
                                    	ywlx = "0";
                                    }
                                    toDealCardAppHjl(curRow["DEAL_NO"], "0", ywlx);
                                    $gridview.datagrid("reload");
                                }
                            });
                        }
                    }
                },
                '-',
                {
                    iconCls: 'icon-remove',
                    text:"<span style='font-weight: bold'>撤销</span>",
                    handler: function(){
                        var curRow = $gridview.datagrid("getSelected");
                        if(!curRow || dealNull(curRow["DEAL_NO"]) == ""){
                            jAlert("请勾选一条记录信息进行撤销！","warning");
                            return;
                        }else{
                            $.messager.confirm("系统消息","您确认要取消勾选的应用开通灰记录吗？",function(r){
                                if(r){
                                    $.messager.progress({text:"正在进行取消，请稍后...."});
                                    var ywlx = "1";
                                    if(curRow["DEAL_CODE"] == "<%=DealCode.ZXC_APP_OPEN%>"){
                                    	ywlx = "0";
                                    }
                                    toDealCardAppHjl(curRow["DEAL_NO"],"1", ywlx);
                                    $gridview.datagrid("reload");
                                }
                            });
                        }
                    }
                }
            ]
        });
    });
    function toQueryCardApply(){
        var params = getformdata("viewSearchConts");
        params["queryType"] = "0";
        params["taskList.name"] = $("#name").val();
        $gridview.datagrid("load",params);
    }
</script>
<n:layout>
    <n:center cssStyle="border:none">
        <div id="tbview1" style="display:none;">
            <form id="viewSearchConts">
                <table class="tablegrid">
                    <tr>
                        <td class="tableleft" style="width:7%;">姓名：</td>
                        <td class="tableright" style="width:18%;"><input id="name" name="taskList.name" type="text" class="textinput" maxlength="15"/></td>
                        <td class="tableleft" style="width:7%;">证件号码：</td>
                        <td class="tableright" style="width:18%;"><input id="certNo" name="taskList.certNo" type="text" class="textinput" maxlength="18"/></td>
                        <td class="tableleft" style="width:7%;">卡号：</td>
                        <td class="tableright" style="width:18%;"><input id="cardNo" name="taskList.cardNo" type="text" class="textinput" maxlength="20"/></td>
                        <td class="tableright" colspan="1">
                            <a data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="toQueryCardApply()">查询</a>
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        <table id="dgview" title=""></table>
    </n:center>
</n:layout>